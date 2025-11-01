class GoalsController < ApplicationController
  include Pagy::Backend

  def show
    @goal = current_user.goals.find(params[:id])
    @pagy, @snapshots = pagy(@goal.goal_snapshots.order(extraction_date: :desc), limit: 10)
    @snapshot = @snapshots.first
  end
end
