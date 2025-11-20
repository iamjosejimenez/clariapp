class TableComponent < ViewComponent::Base
  renders_many :columns, ->(name:, classes:, &block) do
    ColumnComponent.new(name: name, classes: classes, &block)
  end

  attr_reader :pagy
  attr_reader :rows

  def initialize(rows:, pagy: nil)
    @rows = rows
    @pagy = pagy
  end

  class ColumnComponent < ViewComponent::Base
    attr_reader :name
    attr_reader :classes
    attr_reader :block

    def initialize(name:, classes: "", &block)
      @name = name
      @classes = classes
      @block = block
    end

    def call(row)
      content = @block.call(row)
      content_tag(:td, content, class: "px-4 py-3 whitespace-nowrap text-sm text-gray-700 #{@classes}")
    end
  end
end
