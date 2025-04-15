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

      snapshot_attrs = goal_data.slice(:nav, :profit, :not_net_deposited, :deposited, :withdrawn)

      goal.goal_snapshots.find_or_initialize_by(created_at: Time.zone.now).tap do |snapshot|
        snapshot.assign_attributes(snapshot_attrs)
        snapshot.save!
      end
    end
  end

  private

  attr_reader :user
end
