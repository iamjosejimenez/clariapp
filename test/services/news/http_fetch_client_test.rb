# frozen_string_literal: true

require "test_helper"

class HttpFetchClientTest < ActiveSupport::TestCase
  def with_replaced_singleton_method(target, method_name, implementation)
    singleton_class = target.singleton_class
    original_defined = singleton_class.method_defined?(method_name) || singleton_class.private_method_defined?(method_name)
    original_method = singleton_class.instance_method(method_name) if original_defined

    singleton_class.define_method(method_name, &implementation)
    yield
  ensure
    if original_defined
      singleton_class.define_method(method_name, original_method)
    else
      singleton_class.remove_method(method_name)
    end
  end

  test "wraps unexpected errors as client errors outside test mode" do
    client = HttpFetchClient.new
    generic_error = RuntimeError.new("certificate verify failed")

    with_replaced_singleton_method(Rails, :env, -> { ActiveSupport::StringInquirer.new("production") }) do
      with_replaced_singleton_method(HTTParty, :get, ->(*) { raise generic_error }) do
        error = assert_raises(HttpFetchClient::Error) do
          client.get("https://example.com/noticia")
        end

        assert_includes(error.message, "certificate verify failed")
      end
    end
  end
end
