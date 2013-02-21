class SessionsController < ApplicationController
  def create
    user_id = params[:user_id]
    if !development_mode?
      flash[:error] = "not in development mode"
      redirect_to :back
    elsif user = User.where(id: user_id).first
      sign_in(:user, user)
      flash[:success] = "Signed in as #{user.email}"
      redirect_to :root
    else
      flash[:error] = "Invalid user given (#{user_id})"
      redirect_to :back
    end
  end
end