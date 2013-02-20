class SessionsController < ApplicationController
  
  before_filter :check_development_mode!
  
  def create
    if params[:user_id].empty?
      flash[:warning] = "Please choose a user"
      redirect_to :back
      return
    end
    
    user = User.find(params[:user_id])
    unless user
      flash[:error] = "No user found for given id"
      redirect_to :back
      return
    end
    
    sign_in(:user, user)
    
    flash[:success] = "Signed in as #{user.email}"
    
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