# frozen_string_literal: true

class AddEncryptedFieldsToGoal < ActiveRecord::Migration[8.0]
  def change
    add_column :goals, :nav_encrypted, :text
    add_column :goals, :profit_encrypted, :text
    add_column :goals, :not_net_deposited_encrypted, :text
    add_column :goals, :deposited_encrypted, :text
    add_column :goals, :withdrawn_encrypted, :text
  end
end
