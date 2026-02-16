# frozen_string_literal: true

class AddLatestTotalsToGoals < ActiveRecord::Migration[8.0]
  def change
    add_column :goals, :nav, :decimal, precision: 15, scale: 2
    add_column :goals, :deposited, :decimal, precision: 15, scale: 2
    add_column :goals, :withdrawn, :decimal, precision: 15, scale: 2
    add_column :goals, :profit, :decimal, precision: 15, scale: 2
    add_column :goals, :not_net_deposited, :decimal, precision: 15, scale: 2
  end
end
