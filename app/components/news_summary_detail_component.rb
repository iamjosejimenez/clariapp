# frozen_string_literal: true

class NewsSummaryDetailComponent < ViewComponent::Base
  def initialize(summary:)
    @summary = summary
  end
end
