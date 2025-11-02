# frozen_string_literal: true

class InvoicesController < ApplicationController
  def new
    @items = []
  end

  def create
    uploaded_image = invoice_params[:image]
    if uploaded_image.blank?
      respond_to do |format|
        format.html do
          flash.now[:alert] = "Selecciona una imagen de factura."
          @items = []
          render :new, status: :unprocessable_entity
        end
        format.json { render json: { error: "image param is required" }, status: :bad_request }
      end
      return
    end

    items = InvoiceItemExtractionService.new(uploaded_image).call

    respond_to do |format|
      format.html do
        flash.now[:notice] = "Items extraídos correctamente."
        @items = normalize_items(items)
        render :new, status: :ok
      end
      format.json { render json: { items: items }, status: :ok }
    end
  rescue InvoiceItemExtractionService::Error => e
    Rails.logger.error("[InvoicesController] #{e.message}")
    respond_to do |format|
      format.html do
        flash.now[:alert] = e.message
        @items = []
        render :new, status: :bad_gateway
      end
      format.json { render json: { error: e.message }, status: :bad_gateway }
    end
  end

  private

  def invoice_params
    params.permit(:image)
  end

  def normalize_items(items)
    Array(items).map do |item|
      next item unless item.respond_to?(:to_h)

      item
        .to_h
        .transform_keys { |key| key.to_s }
        .with_indifferent_access
    end
  end
end
