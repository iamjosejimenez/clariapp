class FetchGoalSnapshotsJob < ApplicationJob
  queue_as :default

  def perform
    ExternalAccount.where(provider: "fintual").find_each do |external_account|
      next if external_account.access_token.blank?

      logger.info "Fetching goal snapshots for external account #{external_account.id}"
      SyncGoalsService.new(external_account).call
    end

    ExternalAccount.where(provider: "tests").find_each do |external_account|
      external_account.goals.each do |goal|
        FactoryBot.create(:goal_snapshot, goal: goal, extraction_date: Date.current)
      end
    end
  end
end
