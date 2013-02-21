class RepositoriesController < ApplicationController
  
  def index
    @repositories = Repository.page params[:page]
  end
  
end