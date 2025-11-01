class DashboardsController < ApplicationController
  def show
    @fintual_user = current_user.fintual_user
    @goals = @fintual_user&.goals || []
    @total_available = @goals.map(&:nav).map(&:to_f).sum

    @test_user = current_user.tests_user
    @test_goals = @test_user&.goals || []
    @test_total_available = @test_goals.map(&:nav).map(&:to_f).sum
  end

  def update_goals
    SyncGoalsService.new(current_user.fintual_user).call
    redirect_to dashboard_path, notice: "Objetivos actualizados"
  end
end
