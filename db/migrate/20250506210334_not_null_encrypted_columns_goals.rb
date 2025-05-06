class NotNullEncryptedColumnsGoals < ActiveRecord::Migration[8.0]
  def change
    change_column_null :goals, :nav, false
    change_column_null :goals, :profit, false
    change_column_null :goals, :not_net_deposited, false
    change_column_null :goals, :deposited, false
    change_column_null :goals, :withdrawn, false

    change_column_null :goal_snapshots, :nav, false
    change_column_null :goal_snapshots, :profit, false
    change_column_null :goal_snapshots, :not_net_deposited, false
    change_column_null :goal_snapshots, :deposited, false
    change_column_null :goal_snapshots, :withdrawn, false
  end
end
