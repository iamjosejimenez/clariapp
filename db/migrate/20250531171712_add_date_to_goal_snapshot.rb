class AddDateToGoalSnapshot < ActiveRecord::Migration[8.0]
  def change
    add_column :goal_snapshots, :extraction_date, :date, null: true
  end
end
