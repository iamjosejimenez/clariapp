class DeleteRawColumnsGoals < ActiveRecord::Migration[8.0]
  def change
    remove_column :goals, :nav
    remove_column :goals, :profit
    remove_column :goals, :not_net_deposited
    remove_column :goals, :deposited
    remove_column :goals, :withdrawn

    remove_column :goal_snapshots, :nav
    remove_column :goal_snapshots, :profit
    remove_column :goal_snapshots, :not_net_deposited
    remove_column :goal_snapshots, :deposited
    remove_column :goal_snapshots, :withdrawn
  end
end
