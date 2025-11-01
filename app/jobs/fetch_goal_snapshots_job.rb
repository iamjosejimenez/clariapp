class FetchGoalSnapshotsJob < ApplicationJob
  queue_as :default

  def perform
    ExternalAccount.where(provider: "fintual").find_each do |user|
      next if user.access_token.blank?

      logger.info "Fetching goal snapshots for user #{user.id}"
      SyncGoalsService.new(user).call
    end

    ExternalAccount.where(provider: "tests").find_each do |user|
      user.goals.each do |goal|
        FactoryBot.create(:goal_snapshot, goal: goal, extraction_date: Date.current)
      end
    end
  end
end
