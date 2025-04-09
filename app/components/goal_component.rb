# frozen_string_literal: true

class GoalComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(id:, name:, nav:)
    @id = id
    @name = name
    @nav = nav
  end
end
