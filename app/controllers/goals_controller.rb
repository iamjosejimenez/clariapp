class GoalsController < ApplicationController
  include Pagy::Backend

  before_action :require_login

  def show
    @goal = Goal.find(params[:id])
    @snapshot = @goal.goal_snapshots.order(created_at: :desc).first
  end

  def snapshots
    @goal = Goal.find(params[:id])
    @pagy, @snapshots = pagy(@goal.goal_snapshots.order(created_at: :desc))
    render(GoalSnapshotsTableComponent.new(snapshots: @snapshots, pagy: @pagy), layout: false)
  end

  private

  def require_login
    redirect_to root_path, alert: "Tenés que iniciar sesión" unless session[:token].present?
  end
end
