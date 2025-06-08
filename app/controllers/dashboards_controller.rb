class DashboardsController < ApplicationController
  def show
    @goals = current_user.fintual_user&.goals || []
    @total_available = @goals.map(&:nav).map(&:to_f).sum
  end

  def update_goals
    SyncGoalsService.new(current_user.fintual_user).call
    redirect_to dashboard_path, notice: "Objetivos actualizados"
  end
end
