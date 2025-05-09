class SyncGoalsService
  def initialize(user)
    @user = user
  end

  def call
    goals = FintualApi.new(user).fetch_goals

    goals.each do |goal_data|
      goal = Goal.find_or_initialize_by(external_id: goal_data[:id]) do |g|
        g.name = goal_data[:name]
        g.user = user
      end

      goal.nav = goal_data[:nav]
      goal.profit = goal_data[:profit]
      goal.not_net_deposited = goal_data[:not_net_deposited]
      goal.deposited = goal_data[:deposited]
      goal.withdrawn = goal_data[:withdrawn]
      goal.external_created_at = goal_data[:created_at]
      goal.save!

      goal.goal_snapshots.find_or_initialize_by(created_at: Time.zone.now).tap do |snapshot|
        snapshot.nav = goal_data[:nav]
        snapshot.profit = goal_data[:profit]
        snapshot.not_net_deposited = goal_data[:not_net_deposited]
        snapshot.deposited = goal_data[:deposited]
        snapshot.withdrawn = goal_data[:withdrawn]
        snapshot.save!
      end
    end
  end

  private

  attr_reader :user
end
