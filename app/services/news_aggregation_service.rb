class NewsAggregationService
  class Error < StandardError; end

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
    tool_call = assistant_message.tool_calls.first
    function_name = tool_call.function.name
    unless function_name == "web_search"
      raise Error, "Unexpected function call: #{function_name}"
    end

    args = JSON.parse(tool_call.function.arguments)

    # 3. Ejecutar búsqueda con Serper
    search_results = WebSearchService.new(
      query: args["query"],
      num_results: args["num_results"] || 5
    ).call

    # 4. Segunda solicitud con resultados de búsqueda
    final_response = @client.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        *initial_messages,
        {
          role: "assistant",
          content: nil,
          tool_calls: assistant_message.tool_calls
        },
        *search_results.map.with_index { |result, i| { role: "tool", content: result.to_json, tool_call_id: assistant_message.tool_calls[i].id } }
      ]
    })

    # 5. Extraer resumen final
    summary_content = final_response.choices.first.message.content

    if summary_content.blank?
      raise Error, "OpenAI returned empty summary"
    end

    # 6. Crear NewsSummary GLOBAL y NewsItems
    create_news_summary(summary_content, search_results)
  end

  def initial_messages
    [
      {
        role: "system",
        content: "Eres un asistente especializado en noticias económicas de Chile. "\
                "Busca noticias recientes y genera un resumen conciso en español. "\
                "Identifica las 5-7 noticias más importantes y proporciona contexto relevante."
      },
      {
        role: "user",
        content: "Busca y resume las noticias económicas más importantes de Chile de los últimos días. "\
                "Enfócate en: economía general, mercados, BCCh, tipo de cambio, y grandes empresas chilenas."
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
              description: "Búsqueda sobre economía chilena"
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
    # Crear UN resumen global (sin user_id)
    news_summary = NewsSummary.create!(
      title: "Resumen Económico Chile - #{Date.current.strftime('%d/%m/%Y')}",
      summary: summary_content,
      generation_date: Date.current,
      sources_count: search_results.size
    )

    # Crear NewsItems individuales
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
  rescue ActiveRecord::RecordInvalid => e
    raise Error, "Failed to create news summary: #{e.message}"
  end
end
