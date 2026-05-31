# frozen_string_literal: true

class HardenExternalAccountAndGoalUniqueness < ActiveRecord::Migration[8.1]
  class MigrationExternalAccount < ActiveRecord::Base
    self.table_name = "external_accounts"

    has_many :goals,
      class_name: "HardenExternalAccountAndGoalUniqueness::MigrationGoal",
      foreign_key: :external_account_id,
      dependent: :nullify
  end

  class MigrationGoal < ActiveRecord::Base
    self.table_name = "goals"

    belongs_to :external_account,
      class_name: "HardenExternalAccountAndGoalUniqueness::MigrationExternalAccount",
      foreign_key: :external_account_id,
      optional: true

    has_many :goal_snapshots,
      class_name: "HardenExternalAccountAndGoalUniqueness::MigrationGoalSnapshot",
      foreign_key: :goal_id,
      dependent: :nullify
  end

  class MigrationGoalSnapshot < ActiveRecord::Base
    self.table_name = "goal_snapshots"

    belongs_to :goal,
      class_name: "HardenExternalAccountAndGoalUniqueness::MigrationGoal",
      foreign_key: :goal_id,
      optional: true
  end

  def up
    consolidate_duplicate_external_accounts!

    add_index :external_accounts, [ :user_id, :provider ], unique: true, name: "index_external_accounts_on_user_id_and_provider"
    add_index :goals, [ :external_account_id, :external_id ], unique: true, name: "index_goals_on_external_account_id_and_external_id"
  end

  def down
    remove_index :goals, name: "index_goals_on_external_account_id_and_external_id"
    remove_index :external_accounts, name: "index_external_accounts_on_user_id_and_provider"
  end

  private

  def consolidate_duplicate_external_accounts!
    duplicate_groups = MigrationExternalAccount
      .select(:user_id, :provider)
      .group(:user_id, :provider)
      .having("COUNT(*) > 1")

    duplicate_groups.each do |group|
      accounts = MigrationExternalAccount
        .where(user_id: group.user_id, provider: group.provider)
        .order(updated_at: :desc, created_at: :desc, id: :desc)
        .to_a

      keeper = accounts.shift
      accounts.each do |duplicate|
        merge_external_account!(keeper:, duplicate:)
      end
    end
  end

  def merge_external_account!(keeper:, duplicate:)
    duplicate.goals.find_each do |goal|
      existing_goal = keeper.goals.find_by(external_id: goal.external_id)

      if existing_goal
        goal.goal_snapshots.update_all(goal_id: existing_goal.id)
        goal.destroy!
      else
        goal.update!(external_account_id: keeper.id)
      end
    end

    keeper.update_columns(
      username: keeper.username.presence || duplicate.username,
      access_token: keeper.access_token.presence || duplicate.access_token,
      status: keeper.status.presence || duplicate.status,
      updated_at: [ keeper.updated_at, duplicate.updated_at ].compact.max
    )

    duplicate.destroy!
  end
end
