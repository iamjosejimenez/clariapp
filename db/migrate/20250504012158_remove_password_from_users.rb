# frozen_string_literal: true

class RemovePasswordFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :password, :text
  end
end
