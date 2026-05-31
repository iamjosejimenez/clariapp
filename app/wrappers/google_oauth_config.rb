# frozen_string_literal: true

require "signet/oauth_2/client"

# Centralizes Google OAuth2 configuration and client construction for Gmail access.
#
# Required ENV:
#   GOOGLE_OAUTH_CLIENT_ID
#   GOOGLE_OAUTH_CLIENT_SECRET
#   GOOGLE_OAUTH_REDIRECT_URI  (e.g. https://app.example.com/gmail_sessions/callback)
module GoogleOauthConfig
  AUTHORIZATION_URI = "https://accounts.google.com/o/oauth2/auth"
  TOKEN_CREDENTIAL_URI = "https://oauth2.googleapis.com/token"
  SCOPE = "https://www.googleapis.com/auth/gmail.readonly"

  module_function

  def client_id
    ENV.fetch("GOOGLE_OAUTH_CLIENT_ID")
  end

  def client_secret
    ENV.fetch("GOOGLE_OAUTH_CLIENT_SECRET")
  end

  def redirect_uri
    ENV.fetch("GOOGLE_OAUTH_REDIRECT_URI")
  end

  # Base client shared by the authorization-code exchange and token refresh flows.
  def build_client(**options)
    Signet::OAuth2::Client.new(
      authorization_uri: AUTHORIZATION_URI,
      token_credential_uri: TOKEN_CREDENTIAL_URI,
      client_id: client_id,
      client_secret: client_secret,
      scope: SCOPE,
      redirect_uri: redirect_uri,
      **options
    )
  end

  # URL the user is redirected to in order to grant access.
  # access_type=offline + prompt=consent ensures we receive a refresh_token.
  def authorization_url(state:)
    build_client.authorization_uri(
      access_type: "offline",
      prompt: "consent",
      include_granted_scopes: "true",
      state: state
    ).to_s
  end
end
