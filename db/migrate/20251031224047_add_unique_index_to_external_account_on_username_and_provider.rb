# frozen_string_literal: true

class AddUniqueIndexToExternalAccountOnUsernameAndProvider < ActiveRecord::Migration[8.1]
  def change
    add_index :external_accounts, [ :username, :provider ], unique: true
  end
end
