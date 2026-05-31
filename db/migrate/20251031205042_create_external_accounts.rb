# frozen_string_literal: true

class CreateExternalAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :external_accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider
      t.string :access_token
      t.string :status

      t.timestamps
    end
  end
end
