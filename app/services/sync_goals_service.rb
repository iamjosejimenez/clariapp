class SyncGoalsService
  def initialize(external_account)
    @external_account = external_account
  end

  def call
    goals = FintualApi.new(external_account).fetch_goals
    return if goals.blank?

    extraction_date = Date.current

    goals.each do |goal_data|
      goal = Goal.find_or_initialize_by(external_id: goal_data[:id]) do |g|
        g.name = goal_data[:name]
        g.external_account = external_account
      end

      goal.nav = goal_data[:nav]
      goal.profit = goal_data[:profit]
      goal.not_net_deposited = goal_data[:not_net_deposited]
      goal.deposited = goal_data[:deposited]
      goal.withdrawn = goal_data[:withdrawn]
      goal.external_created_at = goal_data[:created_at]
      goal.save!

      goal.goal_snapshots.find_or_initialize_by(extraction_date: extraction_date).tap do |snapshot|
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

  attr_reader :external_account
end
