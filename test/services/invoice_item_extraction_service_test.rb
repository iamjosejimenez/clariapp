# frozen_string_literal: true

require "test_helper"

class InvoiceItemExtractionServiceTest < ActiveSupport::TestCase
  setup do
    @previous_api_key = ENV["OPENAI_API_KEY"]
    ENV["OPENAI_API_KEY"] = "test-api-key"
  end

  teardown do
    ENV["OPENAI_API_KEY"] = @previous_api_key
  end

  test "returns parsed items from OpenAI response" do
    uploaded_file = build_uploaded_file("fake image data", "invoice.png", "image/png")
    response_payload = {
      "choices" => [
        {
          "message" => {
            "content" => <<~JSON
              {
                "items": [
                  {"name": "Widget", "quantity": 2, "unit_price": 5.0, "total": 10.0},
                  {"name": "Gadget", "quantity": 1, "unit_price": 12.5, "total": 12.5}
                ]
              }
            JSON
          }
        }
      ]
    }

    fake_response = Struct.new(:success?, :code, :parsed_response).new(true, 200, response_payload)

    HTTParty.stub(:post, fake_response) do
      items = InvoiceItemExtractionService.new(uploaded_file).call

      assert_equal 2, items.size
      assert_equal "Widget", items.first["name"]
      assert_equal 12.5, items.last["total"]
    end
  end

  test "parses json wrapped in code fences" do
    uploaded_file = build_uploaded_file("fake image data", "invoice.png", "image/png")
    response_payload = {
      "choices" => [
        {
          "message" => {
            "content" => <<~JSON
              ```json
              {
                "items": [
                  {"name": "Servicios de Salud Humana", "quantity": null, "unit_price": null, "total": 71990}
                ]
              }
              ```
            JSON
          }
        }
      ]
    }

    fake_response = Struct.new(:success?, :code, :parsed_response).new(true, 200, response_payload)

    HTTParty.stub(:post, fake_response) do
      items = InvoiceItemExtractionService.new(uploaded_file).call

      assert_equal 1, items.size
      assert_equal "Servicios de Salud Humana", items.first["name"]
      assert_nil items.first["quantity"]
    end
  end

  test "parses array based response segments" do
    uploaded_file = build_uploaded_file("fake image data", "invoice.png", "image/png")
    response_payload = {
      "choices" => [
        {
          "message" => {
            "content" => [
              {
                "type" => "text",
                "text" => <<~JSON
                  ```json
                  {"items":[{"name":"Segmented", "quantity":1, "unit_price":1000, "total":1000}]}
                  ```
                JSON
              }
            ]
          }
        }
      ]
    }

    fake_response = Struct.new(:success?, :code, :parsed_response).new(true, 200, response_payload)

    HTTParty.stub(:post, fake_response) do
      items = InvoiceItemExtractionService.new(uploaded_file).call

      assert_equal 1, items.size
      assert_equal "Segmented", items.first["name"]
    end
  end

  test "accepts hash response with items" do
    uploaded_file = build_uploaded_file("fake image data", "invoice.png", "image/png")
    response_payload = {
      "choices" => [
        {
          "message" => {
            "content" => {
              "items" => [
                { "name" => "Hash Item", "quantity" => 2, "unit_price" => 30.0, "total" => 60.0 }
              ]
            }
          }
        }
      ]
    }

    fake_response = Struct.new(:success?, :code, :parsed_response).new(true, 200, response_payload)

    HTTParty.stub(:post, fake_response) do
      items = InvoiceItemExtractionService.new(uploaded_file).call

      assert_equal 1, items.size
      assert_equal 60.0, items.first["total"]
    end
  end

  private

  def build_uploaded_file(contents, filename, content_type)
    file = Tempfile.new(filename)
    file.write(contents)
    file.rewind

    ActionDispatch::Http::UploadedFile.new(
      tempfile: file,
      filename: filename,
      type: content_type
    )
  end
end
