class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :development_mode?
  
  def development_mode?
    Rails.env.development?
  end
  
  def after_sign_in_path_for(resource_or_scope)
    root_path
  end
end
