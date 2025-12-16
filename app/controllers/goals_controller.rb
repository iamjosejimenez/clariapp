class GoalsController < ApplicationController
  include Pagy::Method

  def show
    @goal = current_user.goals.find(params[:id])
    @snapshots = @goal.goal_snapshots.order(extraction_date: :desc)
    @snapshot = @goal.goal_snapshots.order(created_at: :desc).limit(1).first
  end
end
