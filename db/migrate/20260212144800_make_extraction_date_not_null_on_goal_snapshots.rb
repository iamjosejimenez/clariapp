# frozen_string_literal: true

class MakeExtractionDateNotNullOnGoalSnapshots < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL
      UPDATE goal_snapshots
      SET extraction_date = DATE(created_at)
      WHERE extraction_date IS NULL
    SQL

    change_column_null :goal_snapshots, :extraction_date, false
  end

  def down
    change_column_null :goal_snapshots, :extraction_date, true
  end
end
