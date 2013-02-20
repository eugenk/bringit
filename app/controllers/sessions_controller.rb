class SessionsController < ApplicationController
  
  before_filter :check_development_mode!
  
  def create
    user = User.find(params[:user_id])
    session["warden.user.user.key"] = ["User", user.id, nil]
    
    flash[:success] = "Signed in as #{user.name}"
    
    redirect_to :root
  end
  
  protected
  
  def check_development_mode!
    unless development_mode?
      flash[:error] = "not in development mode"
      redirect_to :back
    end
  rescue ActionController::RedirectBackError
    redirect_to root_path
  end
  
end