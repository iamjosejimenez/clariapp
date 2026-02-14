# frozen_string_literal: true

class ModuleHeaderComponent < ViewComponent::Base
  def initialize(title:, description:)
    @title = title
    @description = description
  end
end
