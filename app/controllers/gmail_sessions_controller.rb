# frozen_string_literal: true

require "google/apis/gmail_v1"

class GmailSessionsController < ApplicationController
  def new
    @gmail_account = current_user.gmail_account
  end

  def authorize
    session[:gmail_oauth_state] = SecureRandom.hex(24)
    redirect_to GoogleOauthConfig.authorization_url(state: session[:gmail_oauth_state]),
      allow_other_host: true
  end

  def callback
    if params[:error].present? || invalid_state?
      return redirect_to gmail_sessions_new_path, alert: "No se pudo conectar la cuenta de Gmail."
    end

    client = exchange_code(params[:code])
    gmail_account = build_account(client)

    if gmail_account.save
      redirect_to gmail_sessions_new_path, notice: "Cuenta de Gmail conectada correctamente."
    else
      redirect_to gmail_sessions_new_path, alert: gmail_account.errors.full_messages.to_sentence
    end
  ensure
    session.delete(:gmail_oauth_state)
  end

  def sync
    gmail_account = current_user.gmail_account
    return redirect_to gmail_sessions_new_path, alert: "Primero conecta tu cuenta de Gmail." if gmail_account.blank?

    if SyncBankEmailsService.new(gmail_account).call
      redirect_to bank_emails_path, notice: "Sincronización completada."
    else
      redirect_to gmail_sessions_new_path,
        alert: "No se pudo sincronizar: la conexión con Gmail expiró o fue revocada. Vuelve a conectar tu cuenta."
    end
  end

  def destroy
    current_user.gmail_account&.destroy
    redirect_to gmail_sessions_new_path, notice: "Cuenta de Gmail desconectada."
  end

  private

  def invalid_state?
    params[:state].blank? || params[:state] != session[:gmail_oauth_state]
  end

  def exchange_code(code)
    client = GoogleOauthConfig.build_client(code: code)
    client.fetch_access_token!
    client
  end

  def build_account(client)
    account = current_user.gmail_account || current_user.build_gmail_account
    account.assign_attributes(
      email: fetch_email_address(client.access_token),
      access_token: client.access_token,
      refresh_token: client.refresh_token,
      token_expires_at: client.expires_at,
      status: "active"
    )
    account
  end

  # Reads the connected mailbox address via the Gmail profile endpoint.
  def fetch_email_address(access_token)
    service = Google::Apis::GmailV1::GmailService.new
    service.authorization = GoogleOauthConfig.build_client(access_token: access_token)
    service.get_user_profile("me").email_address
  end
end
