class FintualSessionsController < ApplicationController
  def new
    redirect_to dashboard_path if current_user.fintual_user.present?
  end

  def create
    email = params[:email]
    password = params[:password]

    response = HTTParty.post("https://fintual.cl/api/access_tokens",
      body: JSON.generate({ user: { email:, password: } }),
      headers: { "Content-Type" => "application/json" }
    )

    if response.code == 201
      body = JSON.parse(response.body.to_s)
      token = body["data"]["attributes"]["token"]

      external_account = ExternalAccount.find_or_initialize_by(username: email, provider: "fintual")
      external_account.user = current_user
      external_account.status = "active"
      external_account.access_token = token
      external_account.save!

      redirect_to dashboard_path
    else
      redirect_to fintual_sessions_new_path, alert: "Correo electrónico o contraseña incorrectos."
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Sesión cerrada correctamente."
  end
end
