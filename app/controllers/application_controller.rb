class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_user
  helper_method :require_login

  def current_user
    @current_user ||= FintualUser.find_by(email: session[:email])
  end

  def require_login
    redirect_to root_path, alert: "Tienes que iniciar sesión" unless session[:email].present?
  end
end
