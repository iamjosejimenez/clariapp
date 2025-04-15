class AddUserToGoals < ActiveRecord::Migration[8.0]
  def change
    add_reference :goals, :user, null: false, foreign_key: true
  end
end
