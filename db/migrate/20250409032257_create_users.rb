# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.text :password
      t.text :token

      t.timestamps
    end
  end
end
