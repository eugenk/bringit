class RepositoriesController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :upload, :destroy, :update, :delete_file, :update_file]
  
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
    show_assignments
  rescue ActiveRecord::RecordNotFound, TypeError
    raise ActionController::RoutingError.new('Not Found')
  end
  
  def entries_info
    @repository = Repository.identifier(params[:id]).first!
    @oid = params[:oid]
    @url = @repository.get_url(@oid, params[:url])
    render json: @repository.entries_info(@oid, @url)
  end

  def commits
    @repository = Repository.identifier(params[:id]).first!
    @commits = @repository.all_commits.page params[:page]
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
      flash[:error] = all_errors
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
        flash[:error] = all_errors
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
    @repository = Repository.identifier(params[:id]).first!
    @url = params[:url] || ''
    @url = url[0..-2] if(@url[-1] == '/')
    params[:message].strip!
    
    if !params[:message] || params[:message].empty?
      flash[:error] = "Please enter a commit message"
      redirect_to browse_repository_path(@repository.path, @url)
    elsif !params[:file]
      flash[:error] = "Please choose a file to upload"
      redirect_to browse_repository_path(@repository.path, @url)
    else
      file_path = @repository.build_target_path(@url, params[:file].original_filename)
      @repository.add_file(current_user, params[:file].tempfile, file_path, params[:message])
      flash[:success] = 'File was added'
      redirect_to browse_repository_path(@repository.path, Repository.directory(file_path))
    end
  end

  def update_file
    params[:message].strip!
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
    general_assignments
    @current_file = @repository.get_current_file(@oid, @url)
    
    render text: @current_file[:content], content_type: Mime::Type.lookup('application/force-download')
  end
  
  def history
    @repository = Repository.identifier(params[:id]).first!
    general_assignments
    @current_commit = @is_head ? nil : @repository.all_commits.identifier(@oid).first!
    @current_file = @repository.get_current_file(@oid, @url)
    @breadcrumbs = @url.split('/')
    @commits = Commit.identifiers(@repository.entry_info_list(@url, @oid), @repository).page params[:page]
  rescue ActiveRecord::RecordNotFound, TypeError
    raise ActionController::RoutingError.new('Not Found')
  end
  
  def delete_file
    get_file
    @repository.delete_file(current_user, @url)
    flash[:success] = 'File was deleted'
    redirect_to repository_path(@repository.path)
  end
  
  def diff
    @repository = Repository.identifier(params[:id]).first!
    basic_assignments
    @current_commit = @repository.all_commits.identifier(@oid).first!
    @changed_files = @repository.get_changed_files(@oid)
  rescue ActiveRecord::RecordNotFound, TypeError
    raise ActionController::RoutingError.new('Not Found')
  end

  protected
  def get_file
    @repository = Repository.identifier(params[:id]).first!
    @url = @repository.get_url(nil, params[:url])
    @current_file = @repository.get_current_file(nil,@url)
  end

  def show_assignments
    general_assignments
    @current_commit = @is_head ? nil : @repository.all_commits.identifier(@oid).first!
    @contents = @repository.folder_contents(@oid, @url)
    @breadcrumbs = @url.split('/')
    @current_file = @repository.get_current_file(@oid, @url)
  end

  def general_assignments
    basic_assignments
    @url = @repository.get_url(@oid, params[:url])
  end

  def basic_assignments
    @oid = params[:oid]
    @is_head = @repository.is_head?(@oid)
  end

  def all_errors
    @repository.errors.messages.map { |field, error| "#{field} #{error.join(", ")}." }.join(" ")
  end
end