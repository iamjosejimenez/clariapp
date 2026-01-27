# frozen_string_literal: true

class GoalSnapshotDetailComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(snapshot:)
    @snapshot = snapshot
  end
end
