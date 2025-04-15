# frozen_string_literal: true

class GoalSnapshotsTableComponent < ViewComponent::Base
  include ApplicationHelper
  include Pagy::Frontend

  def initialize(snapshots:, pagy:)
    @snapshots = snapshots
    @pagy = pagy
  end
end
