class Goal < ApplicationRecord
  has_many :goal_snapshots, dependent: :destroy
end
