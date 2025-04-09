class SessionsController < ApplicationController
  def new
  end

  def create
    email = params[:email]
    password = params[:password]

    response = HTTP.post("https://fintual.cl/api/access_tokens", json: {
      user: { email:, password: }
    })

    if response.code == 201
      body = JSON.parse(response.body.to_s)
      token = body["data"]["attributes"]["token"]

      user = User.find_or_initialize_by(email:)
      debugger
      user.password = password
      user.token = token
      user.save!

      session[:email] = email
      session[:token] = token

      redirect_to dashboard_path
    else
      flash.now[:alert] = "Email o contraseña incorrectos"
      render :new, status: :unauthorized
    end
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
