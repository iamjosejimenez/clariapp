# frozen_string_literal: true

class NewsController < ApplicationController
  def index
    @selected_date = parse_date(params[:date]) || Date.current
    @today = Date.current
    @previous_date = @selected_date - 1.day
    @next_date = @selected_date + 1.day
    @next_disabled = @selected_date >= @today

    @summary = NewsSummary.find_by(generation_date: @selected_date)
    @news_items = @summary&.news_items&.order(published_at: :desc, relevance_score: :asc) || []
  end

  def show
    @summary = NewsSummary.find(params[:id])
    @news_items = @summary.news_items.order(published_at: :desc, relevance_score: :asc)
  end

  private

  def parse_date(value)
    return if value.blank?

    Date.iso8601(value)
  rescue ArgumentError
    nil
  end
end
