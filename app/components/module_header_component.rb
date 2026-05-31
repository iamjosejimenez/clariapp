# frozen_string_literal: true

class ModuleHeaderComponent < ApplicationComponent
  def initialize(title:, description:)
    @title = title
    @description = description
  end
end
