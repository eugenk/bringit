class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :development_mode?
  
  protected
  def development_mode?
    Rails.env.development?
  end
  
  def after_sign_in_path_for(resource_or_scope)
    root_path
  end
  
  def require_login
    unless user_signed_in?
      flash[:error] = "Yout must be logged in to access this section"
      redirect_to new_user_session_path
    end
  end
end
