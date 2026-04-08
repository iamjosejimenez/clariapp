# frozen_string_literal: true

class NewsAggregationService
  class Error < StandardError; end
  NEWS_QUERY = "economía chile"
  MAX_RESULTS = 8

  def initialize
  end

  def call
    news_list = WebSearchService.new(
      query: NEWS_QUERY,
      num_pages: 2
    ).call

    openai_client = OpenAI::Client.new

    response = openai_client.responses.create(
      model: "gpt-5.4-nano-2026-03-17",
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

    ordered_indexes = extract_response_text(response).split(",")
    selected_news = []

    ordered_indexes.each do |selected_index|
      next if selected_news.size == MAX_RESULTS

      parsed_index = Integer(selected_index, exception: false)
      next if parsed_index.nil?

      news = news_list[parsed_index]
      next if news.nil?

      url = news["link"]
      content = ArticleContentService.new(url: url).call
      next if content.blank? || content == ArticleContentService::EXTRACTION_FAILURE_MESSAGE

      news["content"] = content
      selected_news << news
    end

    response = openai_client.responses.create(
      model: "gpt-5.4-nano-2026-03-17",
      input: [
        { role: :system, content: "Eres un asistente experto en economía de Chile" },
        summary_request_message(selected_news)
      ],
    )

    summary_content = extract_response_text(response)

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

  def extract_response_text(response)
    text = response.output_text.to_s.strip
    return text if text.present?

    Array(response.output).each do |item|
      next unless item.type == "message"

      Array(item.content).each do |content|
        next unless content.type == "output_text"

        extracted_text = content.text.to_s.strip
        return extracted_text if extracted_text.present?
      end
    end

    raise Error, "OpenAI response did not include any output text"
  end

  def summary_request_message(news_list)
    {
      role: "user",
      content: <<~PROMPT
        A partir de los siguientes resultados de búsqueda de noticias relevantes, genera un resumen analítico de la economía chilena de alta calidad en español. Tu objetivo principal no es resumir noticias por separado, sino integrarlas en una lectura común, conectando sus hallazgos de forma natural y cercana.

        Formato requerido:
        - Primero, exactamente 3 párrafos de texto fluido.
        - Cada párrafo debe desarrollar bien las ideas, con suficiente detalle para que el resumen sea completo y no superficial.
        - Lenguaje claro, cercano y natural.
        - Solo hechos confirmados por las fuentes.
        - Sin corchetes ni paréntesis de plantilla.
        - Los 3 párrafos deben integrar las relaciones más relevantes entre las noticias, pero sin hablar explícitamente de "patrones", "señales", "planos" o "tendencias detectadas".
        - Después de los 3 párrafos, agrega una sección llamada "Puntos claves a seguir:".
        - En "Puntos claves a seguir:", incluye exactamente #{news_list.size} puntos numerados (uno por cada noticia incluida en las fuentes).
        - Cada punto debe integrar en redacción natural el hecho principal, su impacto en la economía chilena, su conexión con el resto del panorama y el motivo de inclusión en el análisis.
        - No uses etiquetas internas como "Hecho principal:", "por qué afecta:" o "por qué se incluye:".

        Reglas:
        - Todo el contenido debe estar 100% en español.
        - No uses palabras en inglés, salvo nombres propios, siglas internacionales o citas textuales estrictamente necesarias.
        - Si aparece un término en inglés en las fuentes, escribe su equivalente en español cuando exista.
        - El contenido de la noticia es el campo "content"; pero también debes usar "snippet" y "title" para validar la información de "content" ya que fue extraído de la web.
        - En los 3 párrafos prioriza interpretación económica y relaciones de causa-efecto; no hagas una lista de noticias ni un resumen secuencial.
        - Detecta relaciones como causas compartidas, efectos encadenados, tensiones entre sectores o cambios de expectativas, pero exprésalas como parte del relato y no como hallazgos explícitamente nombrados.
        - Si dos o más noticias hablan del mismo actor, sector, riesgo, política pública o tendencia, intégralas explícitamente en una sola lectura analítica.
        - Si encuentras contrastes, contradicciones o señales mixtas entre noticias, señálalos y explica su relevancia.
        - Redacta con enfoque analítico: conecta esas relaciones con implicancias en crecimiento, inversión, productividad, empleo, comercio exterior, cuentas fiscales o riesgo país, según corresponda.
        - No uses frases como "las noticias muestran", "el patrón central", "un segundo plano" o "en el plano sectorial"; la lectura debe sentirse más humana y menos estructurada.
        - No sacrifiques información importante por brevedad: incluye matices, contexto y efectos relevantes cuando estén respaldados por las fuentes.
        - Evita formular preguntas explícitas o estructuras de cuestionario; redacta todo en estilo declarativo y analítico.
        - No agregues introducciones ni conclusiones fuera del formato solicitado.
        - Si no hay evidencia suficiente para afirmar una relación, no la inventes; indica la cautela de forma breve y natural.
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
