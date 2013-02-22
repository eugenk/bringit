class RepositoriesController < ApplicationController
  
  autocomplete :repository, :title, full: true, extra_data: [:id], 
    display_value: :autocomplete_value, options: {appendTo: '.form-search .input-append'}
  
  def index
    @repositories = Repository.page params[:page]
  end
  
  def search
    @term = params[:repository][:term]
    @repositories = Repository.search(@term).page params[:page]
  end
  
  def show
    
  end
  
end