# frozen_string_literal: true

require "google/apis/gmail_v1"

# Thin wrapper over the Gmail API for a single connected GmailAccount.
#
# Mirrors the FintualApi pattern: constructed with the credential-holding model,
# exposes high-level fetch methods, and hides authentication details (including
# refreshing the access token when expired).
class GmailApi
  # Gmail sender(s) used by BCI notifications:
  #   contacto@bci.cl       → avisos de compras/cargos
  #   transferencias@bci.cl → transferencias salientes
  BANK_QUERIES = {
    "bci" => "from:(contacto@bci.cl OR transferencias@bci.cl) newer_than:30d"
  }.freeze

  class AuthError < StandardError; end

  def initialize(gmail_account)
    @gmail_account = gmail_account
  end

  # Returns the Gmail message ids matching the bank notification query.
  def fetch_bank_message_ids(bank: "bci")
    query = BANK_QUERIES.fetch(bank)
    ids = []
    page_token = nil

    loop do
      result = service.list_user_messages("me", q: query, page_token: page_token)
      ids.concat(Array(result.messages).map(&:id))
      page_token = result.next_page_token
      break if page_token.blank?
    end

    ids
  end

  # Fetches one message and returns a plain hash of the fields we persist.
  def fetch_message(message_id)
    message = service.get_user_message("me", message_id, format: "full")
    headers = header_map(message.payload)

    {
      gmail_message_id: message.id,
      from_address: headers["from"],
      subject: headers["subject"],
      received_at: received_at_for(message),
      snippet: message.snippet,
      raw_body: extract_body(message.payload)
    }
  end

  private

  attr_reader :gmail_account

  def service
    @service ||= begin
      svc = Google::Apis::GmailV1::GmailService.new
      svc.authorization = authorization
      svc
    end
  end

  # Builds a Signet client from the stored credentials and refreshes the access
  # token if it has expired, persisting the new token back to the account.
  def authorization
    client = GoogleOauthConfig.build_client(
      access_token: gmail_account.access_token,
      refresh_token: gmail_account.refresh_token,
      expires_at: gmail_account.token_expires_at
    )

    refresh_access_token!(client) if gmail_account.token_expired?
    client
  rescue Signet::AuthorizationError => e
    gmail_account.update(status: "error")
    raise AuthError, "Gmail authorization failed: #{e.message}"
  end

  def refresh_access_token!(client)
    client.refresh!
    gmail_account.update!(
      access_token: client.access_token,
      token_expires_at: client.expires_at
    )
  end

  def header_map(payload)
    Array(payload&.headers).each_with_object({}) do |header, map|
      map[header.name.to_s.downcase] = header.value
    end
  end

  def received_at_for(message)
    Time.at(message.internal_date / 1000) if message.internal_date
  end

  # Walks the MIME tree and returns the HTML part if present, otherwise plain text.
  def extract_body(payload)
    return nil if payload.nil?

    html = find_part(payload, "text/html")
    plain = find_part(payload, "text/plain")
    decode(html || plain || payload.body)
  end

  def find_part(payload, mime_type)
    return payload.body if payload.mime_type == mime_type && payload.body&.data.present?

    Array(payload.parts).each do |part|
      found = find_part(part, mime_type)
      return found if found
    end
    nil
  end

  def decode(body)
    return nil if body.nil? || body.data.blank?

    body.data.force_encoding("UTF-8")
  end
end
