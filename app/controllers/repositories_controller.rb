class RepositoriesController < ApplicationController
  before_filter :require_login, only: [:new, :create, :upload, :destroy]
  
  autocomplete :repository, :title, full: true, extra_data: [:path],
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
      @redirect_url = repository_path(@repository.path)
      render template: 'layouts/_redirect', layout: false 
    else
      flash[:error] = @repository.errors.messages.map { |field, error| "#{field} #{error.join(", ")}." }.join(" ")
      render action: '_new', layout: false 
    end
  end
  
  def destroy
    @repository = Repository.identifier(params[:id]).first
    
    if @repository.destroy
      flash[:notice] = 'Repository was successfully removed.'
      redirect_to repositories_path
    else
      flash[:error] = 'Repository can not be removed.'
      redirect_to @repository
    end
  end
  
  def upload
    @repository = Repository.identifier(params[:repository_id]).first
    
    if !params[:message] || params[:message].empty?
      flash[:error] = "Please enter a commit message"
      redirect_to @repository
    elsif !params[:file]
      flash[:error] = "Please choose a file to upload"
      redirect_to @repository
    else
      uploader = FileUploader.new
      uploader.store!(params[:file])
      tmp_path = "#{Rails.root}/public#{uploader.url}"
      @repository.add_commit(current_user, tmp_path, params[:file].original_filename, params[:message])
      File.delete(tmp_path)
      flash[:success] = "File was added"
      redirect_to @repository
    end
  end
  
end