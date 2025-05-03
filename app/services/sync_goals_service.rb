class SyncGoalsService
  def initialize(user)
    @user = user
  end

  def call
    goals = FintualApi.new(user).fetch_goals

    goals.each do |goal_data|
      snapshot_attrs = goal_data.slice(:nav, :profit, :not_net_deposited, :deposited, :withdrawn)
      goal = Goal.find_or_create_by(external_id: goal_data[:id]) do |g|
        g.name = goal_data[:name]
        g.user = user
      end
      debugger
      goal.assign_attributes(
        nav: goal_data[:nav],
        profit: goal_data[:profit],
        not_net_deposited: goal_data[:not_net_deposited],
        deposited: goal_data[:deposited],
        withdrawn: goal_data[:withdrawn],
        external_created_at: goal_data[:created_at],
      )
      goal.save!

      goal.goal_snapshots.find_or_initialize_by(created_at: Time.zone.now).tap do |snapshot|
        snapshot.assign_attributes(snapshot_attrs)
        snapshot.save!
      end
    end
  end

  private

  attr_reader :user
end
