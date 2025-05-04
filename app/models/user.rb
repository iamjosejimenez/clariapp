# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string
#  token      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

class User < ApplicationRecord
  encrypts :password
  encrypts :token

  validates :email, presence: true, uniqueness: true

  has_many :goals, dependent: :destroy
end
