# frozen_string_literal: true

class DatepickerComponent < ViewComponent::Base
  DEFAULT_INPUT_CLASSES = "block w-full ps-9 pe-3 py-2.5 bg-neutral-secondary-medium border border-default-medium text-heading text-sm rounded-base focus:ring-brand focus:border-brand px-3 py-2.5 shadow-xs placeholder:text-body cursor-pointer".freeze
  DEFAULT_CONTAINER_CLASSES = "relative max-w-sm".freeze
  DEFAULT_FORMAT = "dd/mm/yyyy".freeze

  attr_reader :id
  attr_reader :label
  attr_reader :value
  attr_reader :placeholder
  attr_reader :url
  attr_reader :max_date
  attr_reader :controller_name
  attr_reader :target_name
  attr_reader :input_classes
  attr_reader :container_classes
  attr_reader :datepicker_format

  def initialize(
    id:,
    label:,
    value:,
    placeholder:,
    url:,
    max_date:,
    controller_name:,
    target_name:,
    input_classes: DEFAULT_INPUT_CLASSES,
    container_classes: DEFAULT_CONTAINER_CLASSES,
    datepicker_format: DEFAULT_FORMAT)
    @id = id
    @label = label
    @value = value
    @placeholder = placeholder
    @url = url
    @max_date = max_date
    @controller_name = controller_name
    @target_name = target_name
    @input_classes = input_classes
    @container_classes = container_classes
    @datepicker_format = datepicker_format
  end

  def max_date_iso8601
    max_date.iso8601
  end

  def max_date_for_picker
    max_date.strftime(DEFAULT_FORMAT)
  end
end
