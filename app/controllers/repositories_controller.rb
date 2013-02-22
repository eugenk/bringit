class RepositoriesController < ApplicationController
  before_filter :require_login, only: [:new, :create]
  
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
    @repository = Repository.identifier(params[:id]).first
  end
  
  def new
    @repository = Repository.new
    render template: 'repositories/_new', layout: false
  end
  
  def create
    @repository = Repository.new(params[:repository])
    @repository.owners << current_user
    
    if @repository.save
      flash[:notice] = 'Repository was successfully created.'
      @redirect_url = repository_path(@repository)
      render template: 'layouts/_redirect', layout: false 
    else
      render action: '_new', layout: false 
    end
  end
  
end