class NewsController < ApplicationController
  def index
    # All users see the same summary
    @summary = NewsSummary.order(generation_date: :desc).first
    @news_items = @summary&.news_items&.order(published_at: :desc, relevance_score: :asc) || []
  end

  def show
    @summary = NewsSummary.find(params[:id])
    @news_items = @summary.news_items.order(published_at: :desc, relevance_score: :asc)
  end
end
