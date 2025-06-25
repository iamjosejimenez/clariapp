class GoalsController < ApplicationController
  include Pagy::Backend

  def show
    @goal = Goal.find(params[:id])
    @snapshot = @goal.goal_snapshots.order(created_at: :desc).first
    @pagy, @snapshots = pagy(@goal.goal_snapshots.order(created_at: :desc), limit: 10)
  end
end
