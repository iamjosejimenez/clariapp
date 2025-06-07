# == Schema Information
#
# Table name: fintual_users
#
#  id         :integer          not null, primary key
#  email      :string
#  token      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_fintual_users_on_email  (email) UNIQUE
#

class FintualUser < ApplicationRecord
  encrypts :password
  encrypts :token

  validates :email, presence: true, uniqueness: true

  has_many :goals, dependent: :destroy
end
