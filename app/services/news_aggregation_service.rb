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
        A partir de los siguientes resultados de búsqueda de noticias relevantes, genera un análisis de la economía chilena de alta calidad en español.

        Formato requerido:
        - Primero, exactamente 3 párrafos de texto fluido.
        - Lenguaje claro.
        - Solo hechos confirmados por las fuentes.
        - Sin corchetes ni paréntesis de plantilla.
        - Después de los 3 párrafos, agrega una sección llamada "Puntos de seguimiento:".
        - En "Puntos de seguimiento:", incluye exactamente #{news_list.size} puntos numerados (uno por cada noticia incluida en las fuentes).
        - Cada punto debe contener: hecho principal de la noticia, por qué afecta la economía chilena y por qué se incluye en el análisis.

        Reglas:
        - Todo el contenido debe estar 100% en español.
        - No uses palabras en inglés, salvo nombres propios, siglas internacionales o citas textuales estrictamente necesarias.
        - Si aparece un término en inglés en las fuentes, escribe su equivalente en español cuando exista.
        - El contenido de la noticia es el campo "content"; pero también debes usar "snippet" y "title" para validar la información de "content" ya que fue extraído de la web.
        - En los 3 párrafos prioriza interpretación económica y relaciones de causa-efecto; no hagas una lista de noticias.
        - Redacta con enfoque analítico: conecta hechos con implicancias en crecimiento, inversión, productividad, empleo, comercio exterior, cuentas fiscales o riesgo país, según corresponda.
        - Organiza el análisis en tres planos: macrofiscal, competitividad e infraestructura, y desempeño sectorial/exportador (solo si las fuentes disponibles lo permiten).
        - No agregues introducciones ni conclusiones fuera del formato solicitado.
        - Si una noticia tiene información insuficiente o dudosa, no inventes datos; aclara esa limitación en su punto correspondiente.

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
