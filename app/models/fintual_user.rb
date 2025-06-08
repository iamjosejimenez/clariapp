# == Schema Information
#
# Table name: fintual_users
#
#  id         :integer          not null, primary key
#  email      :string
#  token      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_fintual_users_on_email    (email) UNIQUE
#  index_fintual_users_on_user_id  (user_id)
#

class FintualUser < ApplicationRecord
  encrypts :password
  encrypts :token

  validates :email, presence: true, uniqueness: true

  has_many :goals, dependent: :destroy
  belongs_to :user, optional: false
end
