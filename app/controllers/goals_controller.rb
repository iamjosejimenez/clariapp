class GoalsController < ApplicationController
  include Pagy::Method

  def show
    @goal = current_user.goals.find(params[:id])
    @pagy, @snapshots = pagy(:countless, @goal.goal_snapshots.order(extraction_date: :desc), limit: 10)
    @snapshot = @goal.goal_snapshots.order(created_at: :desc).limit(1).first
  end
end
