# frozen_string_literal: true

class NewsItemComponent < ApplicationComponent
  def initialize(item:)
    @item = item
  end
end
