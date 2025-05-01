class FetchGoalSnapshotsJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      next if user.token.blank?

      logger.info "Fetching goal snapshots for user #{user.id}"
      SyncGoalsService.new(user).call
    end
  end
end
