# frozen_string_literal: true

module ApplicationHelper
  PRESENTATION_TIME_ZONE = "Santiago"

  def clp(amount, precision: 0)
    number_to_currency(amount, locale: :"es-CL", precision:, strip_insignificant_zeros: true)
  end

  def chile_date(value, format: :default)
    return if value.blank?

    I18n.l(value.in_time_zone(PRESENTATION_TIME_ZONE).to_date, format:, locale: :"es-CL")
  end

  def chile_datetime(value, format: :compact)
    return if value.blank?

    I18n.l(value.in_time_zone(PRESENTATION_TIME_ZONE), format:, locale: :"es-CL")
  end
end
