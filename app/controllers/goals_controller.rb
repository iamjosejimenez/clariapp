class GoalsController < ApplicationController
  before_action :require_login

  def show
    email = session[:email]
    token = session[:token]

    response = HTTP.get("https://fintual.cl/api/goals/#{params[:id]}", params: {
      user_email: email,
      user_token: token
    })

    if response.code == 200
      body = JSON.parse(response.body.to_s)
      @goal = body["data"]
    else
      redirect_to dashboard_path, alert: "No se pudo cargar el goal"
    end
  end

  private

  def require_login
    redirect_to root_path, alert: "Tenés que iniciar sesión" unless session[:token].present?
  end
end
