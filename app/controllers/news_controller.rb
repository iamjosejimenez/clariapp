# frozen_string_literal: true

class NewsController < ApplicationController
  def index
    @selected_date = parse_date(params[:date])

    @summary = NewsSummary.find_by(generation_date: @selected_date) if @selected_date.present?
    @news_items = @summary&.news_items&.order(published_at: :desc, relevance_score: :asc) || []
  end

  def show
    @summary = NewsSummary.find(params[:id])
    @news_items = @summary.news_items.order(published_at: :desc, relevance_score: :asc)
  end

  private

  def parse_date(value)
    return if value.blank?
    return unless value.is_a?(String)

    Date.iso8601(value)
  rescue ArgumentError, TypeError
    nil
  end
end
