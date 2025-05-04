class DashboardController < ApplicationController
  before_action :require_login

  def show
    SyncGoalsService.new(current_user).call
    @goals = Goal.where(user_id: current_user.id)
    @total_available = @goals.sum(:nav)
  end

  private

  def require_login
    redirect_to root_path, alert: "Tenés que iniciar sesión" unless session[:email].present?
  end
end
