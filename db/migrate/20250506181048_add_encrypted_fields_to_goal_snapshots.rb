class AddEncryptedFieldsToGoalSnapshots < ActiveRecord::Migration[8.0]
  def change
    add_column :goal_snapshots, :nav_encrypted, :text
    add_column :goal_snapshots, :profit_encrypted, :text
    add_column :goal_snapshots, :not_net_deposited_encrypted, :text
    add_column :goal_snapshots, :deposited_encrypted, :text
    add_column :goal_snapshots, :withdrawn_encrypted, :text
  end
end
