# frozen_string_literal: true

require "test_helper"

class NewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in
  end

  test "GET /news sin fecha muestra estado inicial" do
    today = Date.current
    create_news_summary!(date: today, summary_text: "Resumen de hoy")

    get news_index_url

    assert_response :success
    assert_match("Resumen de noticias", response.body)
    assert_match("Selecciona una fecha para ver el resumen de noticias.", response.body)
    refute_match("Resumen de hoy", response.body)
  end

  test "GET /news con fecha valida carga el resumen de esa fecha" do
    target_date = Date.current - 2.days
    create_news_summary!(date: Date.current, summary_text: "Resumen de hoy")
    create_news_summary!(date: target_date, summary_text: "Resumen historico")

    get news_index_url(date: target_date.iso8601)

    assert_response :success
    assert_match("Resumen - #{target_date.strftime('%d/%m/%Y')}", response.body)
    assert_match("Resumen historico", response.body)
    refute_match("Resumen de hoy", response.body)
  end

  test "GET /news con fecha futura no se ajusta a hoy" do
    today = Date.current
    future_date = today + 3.days
    create_news_summary!(date: today, summary_text: "Resumen actual")

    get news_index_url(date: future_date.iso8601)

    assert_response :success
    assert_match("Resumen - #{future_date.strftime('%d/%m/%Y')}", response.body)
    assert_match("No hay resumen disponible para el #{future_date.strftime('%d/%m/%Y')}", response.body)
    refute_match("Resumen actual", response.body)
  end

  test "GET /news con fecha invalida muestra estado inicial" do
    today = Date.current
    create_news_summary!(date: today, summary_text: "Resumen vigente")

    get news_index_url(date: "fecha-invalida")

    assert_response :success
    assert_match("Resumen de noticias", response.body)
    assert_match("Selecciona una fecha para ver el resumen de noticias.", response.body)
    refute_match("Resumen vigente", response.body)
  end

  test "renderiza datepicker y boton para ir a hoy" do
    get news_index_url

    assert_response :success
    assert_select "a", text: /D\u00eda anterior/, count: 0
    assert_select "a", text: /D\u00eda siguiente/, count: 0
    assert_select "div[data-controller='news-datepicker']", count: 1
    assert_select "div[data-news-datepicker-url-value='#{news_index_path}']", count: 1
    assert_select "div[data-news-datepicker-selected-date-value]", count: 0
    assert_select "a[data-action='click->news-datepicker#goToToday']", text: "Ir a hoy", count: 1
    assert_select "input[data-news-datepicker-target='input']", count: 1
    assert_select "input[data-news-datepicker-target='input'][datepicker-max-date]", count: 0
    assert_select "input[data-news-datepicker-target='input'][readonly]", count: 1
  end

  private

  def sign_in
    user = create(:user, password: "password1234*")

    post login_url, params: { email_address: user.email_address, password: "password1234*" }
    assert_response :redirect
  end

  def create_news_summary!(date:, summary_text:)
    NewsSummary.create!(
      generation_date: date,
      title: "Resumen #{date.iso8601}",
      summary: summary_text,
      sources_count: 1
    )
  end
end
