class SyncGoalsService
  def initialize(user)
    @user = user
  end

  def call
    goals = FintualApi.new(user).fetch_goals

    goals.each do |goal_data|
      goal = Goal.find_or_create_by(external_id: goal_data[:id]) do |g|
        g.name = goal_data[:name]
        g.user = user
      end

      goal.assign_attributes(
        nav_encrypted: goal_data[:nav],
        profit_encrypted: goal_data[:profit],
        not_net_deposited_encrypted: goal_data[:not_net_deposited],
        deposited_encrypted: goal_data[:deposited],
        withdrawn_encrypted: goal_data[:withdrawn],
        external_created_at: goal_data[:created_at],
      )
      goal.save!

      goal.goal_snapshots.find_or_initialize_by(created_at: Time.zone.now).tap do |snapshot|
        snapshot.assign_attributes(
          nav_encrypted: goal_data[:nav],
          profit_encrypted: goal_data[:profit],
          not_net_deposited_encrypted: goal_data[:not_net_deposited],
          deposited_encrypted: goal_data[:deposited],
          withdrawn_encrypted: goal_data[:withdrawn],
        )
        snapshot.save!
      end
    end
  end

  private

  attr_reader :user
end
