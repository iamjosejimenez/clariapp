# frozen_string_literal: true

class GoalSnapshotDetailComponent < ApplicationComponent
  def initialize(snapshot:)
    @snapshot = snapshot
  end
end
