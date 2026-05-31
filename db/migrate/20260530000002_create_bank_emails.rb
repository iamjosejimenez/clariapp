# frozen_string_literal: true

class CreateBankEmails < ActiveRecord::Migration[8.1]
  def change
    create_table :bank_emails do |t|
      t.references :gmail_account, null: false, foreign_key: true
      t.string :gmail_message_id, null: false
      t.string :bank, null: false, default: "bci"
      t.string :from_address
      t.string :subject
      t.datetime :received_at
      t.text :raw_body
      t.string :snippet
      t.datetime :processed_at

      t.timestamps
    end

    add_index :bank_emails, :gmail_message_id, unique: true
  end
end
