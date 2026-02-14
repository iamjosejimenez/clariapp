class NewsAggregationService
  class Error < StandardError; end
  MAX_RESULTS_FOR_SUMMARY = 12
  MAX_ARTICLES_WITH_CONTENT = 8

  def initialize
    @client = OpenAI::Client.new # Usa ENV["OPENAI_API_KEY"] automáticamente
  end

  def call
    # 1. Primera solicitud con tools
    response = @client.chat.completions.create({
      model: "gpt-4o-mini",
      temperature: 0.3,
      messages: initial_messages,
      tools: tools_definition,
      tool_choice: "auto"
    })

    message = response.choices.first.message

    # 2. Si OpenAI solicita usar la función web_search
    if message.tool_calls
      process_tool_calls(message)
    else
      raise Error, "OpenAI did not request web search"
    end
  end

  private

  def process_tool_calls(assistant_message)
    tool_calls = assistant_message.tool_calls || []
    raise Error, "OpenAI returned empty tool calls" if tool_calls.empty?

    # 3. Ejecutar búsquedas con Serper para cada tool_call solicitado
    all_search_results = []
    tool_messages = tool_calls.map do |tool_call|
      function_name = tool_call.function.name
      unless function_name == "web_search"
        raise Error, "Unexpected function call: #{function_name}"
      end

      args = JSON.parse(tool_call.function.arguments)
      search_results = WebSearchService.new(
        query: args["query"],
        num_results: args["num_results"] || 5
      ).call
      filtered_search_results = filter_recent_results(search_results)
      all_search_results.concat(filtered_search_results)

      {
        role: "tool",
        content: serialize_results_for_model(filtered_search_results).to_json,
        tool_call_id: tool_call.id
      }
    end

    curated_results = deduplicate_results(all_search_results).first(MAX_RESULTS_FOR_SUMMARY)
    raise Error, "No search results available after filtering" if curated_results.empty?
    enriched_results = enrich_results_with_article_content(curated_results)

    # 4. Segunda solicitud con resultados de búsqueda
    final_response = @client.chat.completions.create({
      model: "gpt-4o-mini",
      temperature: 0.2,
      messages: [
        *initial_messages,
        {
          role: "assistant",
          content: nil,
          tool_calls: assistant_message.tool_calls
        },
        *tool_messages,
        summary_request_message(enriched_results)
      ]
    })

    # 5. Extraer resumen final
    summary_content = final_response.choices.first.message.content

    if summary_content.blank?
      raise Error, "OpenAI returned empty summary"
    end

    # 6. Crear NewsSummary GLOBAL y NewsItems
    create_news_summary(summary_content, curated_results)
  end

  def initial_messages
    today_formatted = today.strftime("%Y-%m-%d")

    [
      {
        role: "system",
        content: "Eres un asistente especializado en noticias económicas de Chile. "\
                "La fecha actual en Chile es #{today_formatted}. "\
                "Busca SOLO noticias económicas publicadas hoy en Chile y genera un resumen conciso en español. "\
                "Si no hay suficientes noticias de hoy, usa las más recientes de las últimas 24 horas e indícalo. "\
                "No inventes datos ni cifras: usa solo lo que aparezca en las fuentes entregadas."
      },
      {
        role: "user",
        content: "Busca y resume las noticias económicas más importantes de Chile de hoy (#{today_formatted}). "\
                "Enfócate en: economía general, mercados, BCCh, tipo de cambio, y grandes empresas chilenas. "\
                "Prioriza medios confiables chilenos y evita noticias antiguas."
      }
    ]
  end

  def tools_definition
    [ {
      type: "function",
      function: {
        name: "web_search",
        description: "Buscar noticias económicas recientes de Chile",
        parameters: {
          type: "object",
          properties: {
            query: {
              type: "string",
              description: "Búsqueda sobre economía chilena de hoy, incluyendo fecha explícita y contexto de Chile"
            },
            num_results: {
              type: "integer",
              description: "Número de resultados (default: 5)",
              default: 5
            }
          },
          required: [ "query" ]
        }
      }
    } ]
  end

  def create_news_summary(summary_content, search_results)
    NewsSummary.transaction do
      # Reemplazar el resumen del día si ya existe.
      NewsSummary.where(generation_date: today).destroy_all

      news_summary = NewsSummary.create!(
        title: "Resumen Económico Chile - #{today.strftime('%d/%m/%Y')}",
        summary: summary_content,
        generation_date: today,
        sources_count: search_results.size
      )

      search_results.each do |result|
        news_summary.news_items.create!(
          title: result[:title],
          source_url: result[:url],
          snippet: result[:snippet],
          category: "economía",
          published_at: result[:date],
          relevance_score: result[:position]
        )
      end

      news_summary
    end
  rescue ActiveRecord::RecordInvalid => e
    raise Error, "Failed to create news summary: #{e.message}"
  end

  def today
    Time.zone.today
  end

  def filter_recent_results(results)
    today_results = results.select { |result| published_on_today?(result[:date]) }
    return today_results if today_results.any?

    recent_results = results.select { |result| published_within_last_24_hours?(result[:date]) }
    return recent_results if recent_results.any?

    undated_results = results.select { |result| result[:date].nil? }
    return undated_results if undated_results.any?

    results
  end

  def published_on_today?(published_at)
    published_at.respond_to?(:to_date) && published_at.to_date == today
  end

  def published_within_last_24_hours?(published_at)
    return false unless published_at.respond_to?(:>)

    published_at > 24.hours.ago
  end

  def summary_request_message(results)
    {
      role: "user",
      content: <<~PROMPT
        Con los resultados de búsqueda y contenido de artículos entregados, genera un resumen de alta calidad en español con este formato exacto:

        Panorama del día:
        [2-3 párrafos, lenguaje claro, solo hechos confirmados por las fuentes]

        Puntos clave:
        - [Punto 1: hecho + impacto económico en Chile]
        - [Punto 2: hecho + impacto económico en Chile]
        - [Punto 3: hecho + impacto económico en Chile]
        - [Punto 4: hecho + impacto económico en Chile]
        - [Punto 5: hecho + impacto económico en Chile]

        Señales para monitorear:
        - [Señal 1]
        - [Señal 2]
        - [Señal 3]

        Reglas:
        - Usa preferentemente el campo "content" cuando exista; usa "snippet" solo como respaldo.
        - Prioriza noticias de hoy y explica cuando un dato es de las últimas 24 horas.
        - Si falta información, escríbelo explícitamente como "No informado en las fuentes".
        - No agregues introducciones ni conclusiones fuera del formato solicitado.

        Fuentes disponibles:
        #{serialize_results_for_model(results).to_json}
      PROMPT
    }
  end

  def serialize_results_for_model(results)
    results.map do |result|
      {
        title: result[:title],
        url: result[:url],
        snippet: result[:snippet],
        content: result[:content],
        published_at: result[:date]&.iso8601,
        position: result[:position]
      }
    end
  end

  def enrich_results_with_article_content(results)
    results.map.with_index do |result, index|
      next result if index >= MAX_ARTICLES_WITH_CONTENT
      next result if result[:url].blank?

      content = ArticleContentService.new(url: result[:url]).call
      content.present? ? result.merge(content: content) : result
    end
  end

  def deduplicate_results(results)
    seen_urls = {}
    seen_titles = {}

    results.each_with_object([]) do |result, acc|
      next if result[:title].blank? && result[:url].blank?

      canonical_url = canonicalize_url(result[:url])
      normalized_title = normalize_title(result[:title])

      next if canonical_url.present? && seen_urls[canonical_url]
      next if normalized_title.present? && seen_titles[normalized_title]

      seen_urls[canonical_url] = true if canonical_url.present?
      seen_titles[normalized_title] = true if normalized_title.present?
      acc << result
    end
  end

  def canonicalize_url(url)
    return nil if url.blank?

    uri = URI.parse(url)
    host = uri.host&.downcase
    return nil if host.blank?

    "#{host}#{uri.path}".gsub(%r{/$}, "")
  rescue URI::InvalidURIError
    nil
  end

  def normalize_title(title)
    return nil if title.blank?

    title.to_s.downcase.gsub(/\s+/, " ").strip
  end
end
