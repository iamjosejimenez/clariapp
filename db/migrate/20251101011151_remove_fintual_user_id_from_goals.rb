# frozen_string_literal: true

class RemoveFintualUserIdFromGoals < ActiveRecord::Migration[8.1]
  def change
    remove_reference :goals, :fintual_user, foreign_key: true, index: true
  end
end
