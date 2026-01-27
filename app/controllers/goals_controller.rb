class GoalsController < ApplicationController
  include Pagy::Method

  def show
    @goal = current_user.goals.find(params[:id])
    @snapshots = @goal.goal_snapshots.order(extraction_date: :desc)
    @snapshot = @goal.goal_snapshots.order(created_at: :desc).limit(1).first
  end

  def snapshot_detail
    @goal = current_user.goals.find(params[:id])
    @snapshot = @goal.goal_snapshots.find(params[:snapshot_id])

    render turbo_stream: turbo_stream.update(
      "modal-content",
      partial: "goals/snapshot_detail",
      locals: { snapshot: @snapshot }
    )
  end
end
