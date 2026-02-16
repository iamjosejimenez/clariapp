# frozen_string_literal: true

class ChangeFieldsToDecimalInGoalSnapshots < ActiveRecord::Migration[8.0]
  def change
    change_column :goal_snapshots, :nav, :decimal, precision: 15, scale: 2
    change_column :goal_snapshots, :profit, :decimal, precision: 15, scale: 2
    change_column :goal_snapshots, :not_net_deposited, :decimal, precision: 15, scale: 2
    change_column :goal_snapshots, :deposited, :decimal, precision: 15, scale: 2
    change_column :goal_snapshots, :withdrawn, :decimal, precision: 15, scale: 2
  end
end
