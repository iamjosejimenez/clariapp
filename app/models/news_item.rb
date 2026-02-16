# frozen_string_literal: true

# == Schema Information
#
# Table name: news_items
# Database name: primary
#
#  id              :integer          not null, primary key
#  category        :string           not null
#  published_at    :datetime         not null
#  relevance_score :decimal(, )      not null
#  snippet         :text             not null
#  source_url      :string           not null
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

  validates :title, :source_url, :snippet, :category, :published_at, :relevance_score, presence: true
  validates :relevance_score, numericality: { greater_than_or_equal_to: 0 }
end
