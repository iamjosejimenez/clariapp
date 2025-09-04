class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    @email_address = ""
    @error = nil
  end

  def create
    form_params = params.permit(:email_address, :password)
    email_address = form_params[:email_address]
    password = form_params[:password]
    if user = User.authenticate_by(email_address:, password: password)
      start_new_session_for user
      redirect_to after_authentication_url
    else
      @error = "Correo o contraseña incorrecta"
      @email_address = email_address
      render :new
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
