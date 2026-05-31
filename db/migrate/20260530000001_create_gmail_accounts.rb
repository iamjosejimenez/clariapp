# frozen_string_literal: true

class CreateGmailAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :gmail_accounts do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :email, null: false
      t.text :refresh_token
      t.text :access_token
      t.datetime :token_expires_at
      t.string :last_history_id
      t.string :status, null: false, default: "active"

      t.timestamps
    end
  end
end
