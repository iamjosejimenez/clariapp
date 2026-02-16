# frozen_string_literal: true

class FetchDailyNewsJob < ApplicationJob
  queue_as :default

  def perform
    logger.info "Generando resumen de noticias global para #{Date.current}"
    begin
      NewsAggregationService.new.call
      logger.info "Resumen de noticias generado exitosamente"
    rescue => e
      logger.error "Error generando resumen de noticias: #{e.message}"
      raise # Re-raise para que Solid Queue pueda reintentar
    end
  end
end
