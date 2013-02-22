class RepositoriesController < ApplicationController
  before_filter :require_login, only: [:new]
  
  autocomplete :repository, :title, full: true, extra_data: [:id], 
    display_value: :autocomplete_value, options: {appendTo: '.form-search .input-append'}
  
  def index
    @repositories = Repository.page params[:page]
  end
  
  def search
    @term = params[:term] || ""
    @repositories = Repository.search(@term).page params[:page]
  end
  
  def show
    
  end
  
  def new
    @repository = Repository.new
    render template: 'repositories/_new', layout: false
  end
  
end