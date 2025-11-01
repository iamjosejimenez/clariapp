class AddExternalAccountToGoals < ActiveRecord::Migration[8.1]
  def change
    add_reference :goals, :external_account, foreign_key: true
  end
end
