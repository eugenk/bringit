class RepositoriesController < ApplicationController
  before_filter :require_login, only: [:new, :create, :upload, :destroy, :update, :delete_file, :update_file]
  
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
    @repository = Repository.identifier(params[:id]).first!
    @url = @repository.get_url(params[:url])
    @contents = @repository.folder_contents_head(@url)
    @breadcrumbs = @url.split('/')
    @current_file = @repository.get_current_file_head(@url)
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
  
  def update
    @repository = Repository.identifier(params[:id]).first!
    if @repository.update_attributes(params[:repository])
      if params[:repository][:title]
        redirect_to @repository, notice: 'Repository was successfully changed.'
      else
        respond_with_bip @repository
      end
    else
      if params[:repository][:title]
        flash[:error] = @repository.errors.messages.map { |field, error| "#{field} #{error.join(", ")}." }.join(" ")
        @repository.reload
        redirect_to @repository
      else
        respond_with_bip @repository
      end
    end
  end
  
  def destroy
    @repository = Repository.identifier(params[:id]).first!
    
    if @repository.destroy
      flash[:notice] = 'Repository was successfully removed.'
      redirect_to repositories_path
    else
      flash[:error] = 'Repository can not be removed.'
      redirect_to @repository
    end
  end
  
  def upload
    @repository = Repository.identifier(params[:repository_id]).first!
    @url = @repository.get_url(params[:url])
    @directory = params[:directory]
    
    if !params[:message] || params[:message].empty?
      flash[:error] = "Please enter a commit message"
      redirect_to browse_repository_path(@repository.path, @url)
    elsif !params[:file]
      flash[:error] = "Please choose a file to upload"
      redirect_to browse_repository_path(@repository.path, @url)
    else
      tmp_path = params[:file].tempfile
      file_path = @url
      file_path << '/' unless file_path.empty?
      file_path << @directory unless @directory.empty?
      file_path << '/' if file_path[-1] != '/' && !file_path.empty?
      suburl = file_path.dup
      file_path << params[:file].original_filename
      @repository.add_file(current_user, tmp_path, file_path, params[:message])
      flash[:success] = 'File was added'
      redirect_to browse_repository_path(@repository.path, suburl)
    end
  end

  def update_file
    get_file
    if !params[:message] || params[:message].empty?
      flash[:error] = "Please enter a commit message"
      redirect_to browse_repository_path(@repository.path, @url)
    else
      @repository.commit_file(current_user, params[:content], @url, params[:message])
      flash[:success] = 'File was committed'
      redirect_to browse_repository_path(@repository.path, @url)
    end
  end
  
  def raw
    @repository = Repository.identifier(params[:id]).first!
    @url = @repository.get_url(params[:url])
    @current_file = @repository.get_current_file_head(@url)
    
    render text: @current_file[:content], content_type: Mime::Type.lookup('application/force-download')
  end
  
  def delete_file
    get_file
    @repository.delete_file(current_user, @url)
    flash[:success] = 'File was deleted'
    redirect_to repository_path(@repository.path)
  end

  protected
  def get_file
    @repository = Repository.identifier(params[:id]).first!
    @url = @repository.get_url(params[:url])
    @current_file = @repository.get_current_file_head(@url)
  end
end