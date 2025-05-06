class DashboardController < ApplicationController
  before_action :require_login

  def show
    SyncGoalsService.new(current_user).call
    @goals = Goal.where(user_id: current_user.id)
    @total_available = @goals.map(&:nav).sum
  end
end
