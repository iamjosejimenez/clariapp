# frozen_string_literal: true

class DeleteEncryptedColumnsGoals < ActiveRecord::Migration[8.0]
  def change
    rename_column :goal_snapshots, :nav_encrypted, :nav
    rename_column :goal_snapshots, :profit_encrypted, :profit
    rename_column :goal_snapshots, :not_net_deposited_encrypted, :not_net_deposited
    rename_column :goal_snapshots, :deposited_encrypted, :deposited
    rename_column :goal_snapshots, :withdrawn_encrypted, :withdrawn

    rename_column :goals, :nav_encrypted, :nav
    rename_column :goals, :profit_encrypted, :profit
    rename_column :goals, :not_net_deposited_encrypted, :not_net_deposited
    rename_column :goals, :deposited_encrypted, :deposited
    rename_column :goals, :withdrawn_encrypted, :withdrawn
  end
end
