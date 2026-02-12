class NewsController < ApplicationController
  def index
    # All users see the same summary
    @summary = NewsSummary.order(generation_date: :desc).first
  end

  def show
    @summary = NewsSummary.find(params[:id])
    @news_items = @summary.news_items.order(created_at: :desc)
  end

  def summary_detail
    @summary = NewsSummary.find(params[:id])

    render turbo_stream: turbo_stream.update(
      "modal-content",
      partial: "news/summary_detail",
      locals: { summary: @summary }
    )
  end

  def refresh
    # Avoid duplicates - only if no summary exists for today
    if NewsSummary.exists?(generation_date: Date.current)
      redirect_to news_index_path, alert: "A summary already exists for today"
      return
    end

    FetchDailyNewsJob.perform_later
    redirect_to news_index_path, notice: "Generating news summary..."
  end
end
