class AddUserToFintualUser < ActiveRecord::Migration[8.0]
  def change
    add_reference :fintual_users, :user, null: true, foreign_key: true
  end
end
