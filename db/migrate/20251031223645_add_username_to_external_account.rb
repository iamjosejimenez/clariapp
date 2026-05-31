# frozen_string_literal: true

class AddUsernameToExternalAccount < ActiveRecord::Migration[8.1]
  def change
    add_column :external_accounts, :username, :string
  end
end
