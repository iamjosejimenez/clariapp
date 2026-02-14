class NewsItemComponent < ViewComponent::Base
  def initialize(item:)
    @item = item
  end
end
