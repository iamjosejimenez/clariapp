# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "chile_date convierte desde utc a la fecha de chile" do
    timestamp = Time.utc(2026, 1, 15, 2, 30, 0)

    assert_equal "14/01/2026", chile_date(timestamp)
  end

  test "chile_datetime convierte desde utc a la zona horaria de chile" do
    timestamp = Time.utc(2026, 1, 15, 2, 30, 0)

    assert_equal "14/01/2026 23:30", chile_datetime(timestamp)
  end
end
