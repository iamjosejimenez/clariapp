# frozen_string_literal: true

class GoalComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(goal:)
    @goal = goal
    @name = goal.name
  end
end
