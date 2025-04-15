# frozen_string_literal: true

class GoalComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(goal:)
    @goal = goal
    @name = goal.name
    @nav = goal.goal_snapshots.order(created_at: :desc).first.nav
  end
end
