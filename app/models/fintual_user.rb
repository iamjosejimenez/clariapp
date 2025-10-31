# == Schema Information
#
# Table name: fintual_users
#
#  id         :bigint           not null, primary key
#  email      :string
#  token      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_fintual_users_on_email    (email) UNIQUE
#  index_fintual_users_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class FintualUser < ApplicationRecord
  encrypts :token

  validates :email, presence: true, uniqueness: true

  has_many :goals, dependent: :destroy
  belongs_to :user, optional: true
end
