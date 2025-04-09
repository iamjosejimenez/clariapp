class CreateGoalSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :goal_snapshots do |t|
      t.references :goal, null: false, foreign_key: true
      t.float :nav
      t.float :profit
      t.float :not_net_deposited
      t.float :deposited
      t.float :withdrawn

      t.timestamps
    end
  end
end
