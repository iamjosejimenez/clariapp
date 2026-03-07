# frozen_string_literal: true

class GoalComponent < ApplicationComponent
  def initialize(goal:)
    @goal = goal
    @name = goal.name
  end
end
