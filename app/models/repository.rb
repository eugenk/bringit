require 'digest/sha1'

class Repository < ActiveRecord::Base
  include CommitGettable, ObjectGettable, FolderContentsGettable, InfoListGettable, DiffGettable, Committable
  attr_accessible :description, :title, :owners
  attr_protected :path, :pushes, :commits, :repo
  
  has_many :repository_owners, foreign_key: 'repository_id', class_name: 'RepositoryOwner'
  has_many :owners, through: :repository_owners, class_name: 'User'
  has_many :pushes, class_name: 'Push', foreign_key: 'repository_id'
  has_many :commits, class_name: 'Commit', through: :pushes, :limit => 3
  has_many :all_commits, class_name: 'Commit', through: :pushes
  
  default_scope order: 'updated_at desc'
  scope :search, ->(term) { where "title LIKE ?", "%" << term << "%" }
  scope :identifier, ->(path) { where "path = ?", path }
  
  paginates_per 10
  max_paginates_per 50
  
  before_validation do |repository|
    return unless repository.title
    repository.path = Repository.title_to_path(repository.title)
  end
  
  after_create :create_repository
  
  before_destroy :destroy_repository
  
  validate :validate_owner_existance
  VALID_TITLE_REGEX = /^[A-Za-z0-9_\.\-\ ]{3,32}$/
  validates :title, presence: true,
                    uniqueness: { case_sensitive: false }, format: VALID_TITLE_REGEX
  VALID_PATH_REGEX = /^[a-z0-9_\.\-]+$/
  validates :path, presence: true, uniqueness: { case_sensitive: true }, format: VALID_PATH_REGEX
  
  def validate_owner_existance
    errors.add :owners, 'has no owner' if owners.empty?
  end
  
  def to_param
    path
  end
  
  def autocomplete_value
    "#{title}"
  end
  
  def ssh_url
    "#{Bringit::Application.config.ssh_base_url}#{path}.git"
  end
  
  def local_path
    "#{Bringit::Application.config.git_root}#{id.to_s}.git"
  end
  
  def contributors
    owners
  end
  
  def self.title_to_path(title)
    title.downcase.tr('^a-z0-9', ' ').gsub(/\ /, '_')
  end
  
  def repo
    @repo ||= Rugged::Repository.new(local_path)
  rescue 
    raise RepositoryNotFoundError
  end

  def path_exists?(commit_oid=nil, url='')
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit && url.empty?
      true
    else
      path_exists_rugged?(rugged_commit, url)
    end
  end

  def get_current_file(commit_oid=nil, url='')
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit && url.empty?
      nil
    else
      get_current_file_rugged(rugged_commit, url)
    end
  end

  def get_url(oid=nil, url=nil)
    url ||= '' 
    url = url[0..-2] if(url[-1] == '/')
    raise ActionController::RoutingError.new('Not Found') unless path_exists?(oid, url)
    
    url
  end

  def self.directory(path)
    path.split("/")[0..-2].join("/")
  end

  def get_branches
    repo.refs.map do |r|
      {
        refname: r.name,
        name: r.name.split('/')[-1],
        oid: r.target
      }
    end
  end
  
  def build_target_path(url, file_name)
    file_path = url.dup
    file_path << '/' if file_path[-1] != '/' && !file_path.empty?
    file_path << file_name
    
    file_path
  end
  
  def is_head?(commit_oid=nil)
    commit_oid == nil || (!repo.empty? && commit_oid == head_oid)
  end
  
  # PROTECTED METHODS

  protected

  def mime_info(filename)
    ext = File.extname(filename)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(ext) || Mime::TEXT
    mime_category = mime_type.to_s.split('/')[0]
    
    {
      mime_type: mime_type,
      mime_category: mime_category
    }
  end

  def get_commit(commit_oid=nil)
    if repo.empty?
      nil
    else
      repo.lookup(commit_oid || head_oid)
    end
  end
  
  def path_exists_rugged?(rugged_commit, url='')
    if url.empty?
      true
    else
      tree = rugged_commit.tree
      nil != get_object(rugged_commit, url)
    end
  rescue Rugged::OdbError
    false
  end
  
  def get_current_file_rugged(rugged_commit, url='')
    return nil unless path_exists_rugged?(rugged_commit, url)
    
    object = get_object(rugged_commit, url)
    
    if object.type == :blob
      filename = url.split('/')[-1]
      mime_info = mime_info(filename)
      {
        name: filename,
        size: object.size,
        content: object.content,
        mime_type: mime_info[:mime_type],
        mime_category: mime_info[:mime_category]
      }
    else
      nil
    end
  end
  
  def create_repository
    repo = Rugged::Repository.init_at(local_path, true)
  end
  
  def destroy_repository
    system "rm -rf #{local_path}"
  end

  def head_oid
    repo.head.target
  end

  def head
    repo.lookup(head_oid)
  end
end
