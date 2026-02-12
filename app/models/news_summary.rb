# == Schema Information
#
# Table name: news_summaries
# Database name: primary
#
#  id              :integer          not null, primary key
#  generation_date :date             not null
#  sources_count   :integer          default(0)
#  summary         :text             not null
#  title           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_news_summaries_on_generation_date  (generation_date) UNIQUE
#

class NewsSummary < ApplicationRecord
  has_many :news_items, dependent: :destroy

  encrypts :summary

  validates :generation_date, presence: true, uniqueness: true
  validates :title, :summary, presence: true
end
