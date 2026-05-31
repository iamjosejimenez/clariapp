# frozen_string_literal: true

class RenameUserToFintualUser < ActiveRecord::Migration[8.0]
  def change
    # Rename the 'users' table to 'fintual_users'
    rename_table :users, :fintual_users

    # Rename the 'user_id' column in the 'goals' table to 'fintual_user_id'
    rename_column :goals, :user_id, :fintual_user_id
  end
end
