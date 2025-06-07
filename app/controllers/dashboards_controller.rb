class DashboardsController < ApplicationController
  before_action :require_login

  def show
    @goals = Goal.where(fintual_user_id: current_user.id)
    @total_available = @goals.map(&:nav).map(&:to_f).sum
  end

  def update_goals
    SyncGoalsService.new(current_user).call
    redirect_to dashboard_path, notice: "Objetivos actualizados"
  end
end
