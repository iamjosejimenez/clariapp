class AddExternalCreatedAtToGoals < ActiveRecord::Migration[8.0]
  def change
    add_column :goals, :external_created_at, :string
  end
end
