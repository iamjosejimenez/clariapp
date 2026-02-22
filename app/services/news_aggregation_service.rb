# frozen_string_literal: true

class NewsAggregationService
  class Error < StandardError; end
  MAX_RESULTS_FOR_SUMMARY = 12
  MAX_ARTICLES_WITH_CONTENT = 8
  NEWS_QUERY = "economía chile"
  MAX_RESULTS = 5

  def initialize
  end

  def call
    news_list = WebSearchService.new(
      query: NEWS_QUERY,
      num_pages: 2
    ).call

    openai_client = OpenAI::Client.new

    response = openai_client.responses.create(
      model: "gpt-5-nano-2025-08-07",
      input: [
        { role: :system, content: "Eres un experto en economía de Chile" },
        {
          role: :user,
          content: <<~CONTENT
            Basado en la siguiente lista de #{news_list.size} noticias, ordena las noticias comenzando por las más importantes para la economía chilena.
            La lista de noticias esta en formato JSON e incluye: title, titulo; snippet, resumen de la noticia; date, fecha relativa a la actual; source, fuente de la noticia;index, o indice.
            Debes retornar SOLO los indices de las noticias separados por coma, por ejemplo 6,0,3,10,15. Solo esa informacion, nada mas.
            Prioriza diferentes fuentes a partir de las más confiables. Noticias:

            #{news_list.to_json}

          CONTENT
        }
      ],
    )

    ordered_indexes = response.output.flat_map { _1.content }.second.text.split(",")
    selected_news = []
    debugger
    ordered_indexes.each do |selected_index|
      next if selected_news.size == MAX_RESULTS

      news = news_list[selected_index.to_i]
      url = news["link"]
      content = ArticleContentService.new(url: url).call
      if content.present?
        news["content"] = content
        selected_news << news
      end
    end

    response = openai_client.responses.create(
      model: "gpt-5-nano-2025-08-07",
      input: [
        { role: :system, content: "Eres un asistente experto en economía de Chile" },
        summary_request_message(selected_news)
      ],
    )

    summary_content = response.output.flat_map { _1.content }.second.text

    create_news_summary(summary_content, selected_news)
  end

  private

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
        news_summary.news_items.create!(build_news_item_attributes(result))
      end

      news_summary
    end
  rescue ActiveRecord::RecordInvalid => e
    raise Error, "Failed to create news summary: #{e.message}"
  end

  def today
    Time.zone.today
  end

  def summary_request_message(news_list)
    {
      role: "user",
      content: <<~PROMPT
        A partir de los siguientes resultados de búsqueda de las noticias más relevants de economia de Chile, genera un resumen de alta calidad en español con este formato exacto:

        [3 párrafos, lenguaje claro, solo hechos confirmados por las fuentes]

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
        - El contenido de la noticia es el campo "content"; pero también debes usar "snippet" y "title" para validar la información de "content" ya que fue extraído de la web.
        - No agregues introducciones ni conclusiones fuera del formato solicitado.

        Fuentes disponibles:
        #{news_list.to_json}
      PROMPT
    }
  end

  def build_news_item_attributes(result)
    {
      title: result["title"].presence || "Sin título",
      source_url: result["link"].presence || "https://sin-fuente.local",
      snippet: result["snippet"].presence || "No disponible",
      category: "economía",
      published_at: Time.zone.now,
      relevance_score: 0
    }
  end
end
