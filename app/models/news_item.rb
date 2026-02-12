# == Schema Information
#
# Table name: news_items
# Database name: primary
#
#  id              :integer          not null, primary key
#  category        :string
#  published_at    :datetime
#  relevance_score :decimal(, )
#  snippet         :text
#  source_url      :string
#  title           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  news_summary_id :integer          not null
#
# Indexes
#
#  index_news_items_on_news_summary_id  (news_summary_id)
#
# Foreign Keys
#
#  news_summary_id  (news_summary_id => news_summaries.id)
#

class NewsItem < ApplicationRecord
  belongs_to :news_summary

  encrypts :snippet

  validates :title, presence: true
end
