class RepositoriesController < ApplicationController
  
  def index
    @repositories = Repository.page params[:page]
  end
  
  def search
    @term = params[:repository][:term]
    @repositories = Repository.search(@term).page params[:page]
  end
  
end