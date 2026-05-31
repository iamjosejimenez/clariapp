# frozen_string_literal: true

class NewsSummaryDetailComponent < ApplicationComponent
  def initialize(summary:)
    @summary = summary
  end
end
