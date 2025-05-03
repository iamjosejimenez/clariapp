class DashboardController < ApplicationController
  before_action :require_login

  def show
    email = session[:email]
    user = User.find_by(email:)
    SyncGoalsService.new(user).call
    @goals = Goal.where(user_id: user.id)
    @total_available = @goals.sum(:nav)
  end

  private

  def require_login
    redirect_to root_path, alert: "Tenés que iniciar sesión" unless session[:token].present?
  end
end
