require 'digest/sha1'

class Repository < ActiveRecord::Base
  attr_accessible :description, :path, :title, :owners, :pushes, :commits, :repo
  
  has_many :repository_owners, foreign_key: 'repository_id', class_name: 'RepositoryOwner'
  has_many :owners, through: :repository_owners, class_name: 'User'
  has_many :pushes, class_name: 'Push', foreign_key: 'repository_id'
  has_many :commits, class_name: 'Commit', through: :pushes, :limit => 3
  
  before_validation do |repository|
    return unless repository.title
    repository.path = Repository.title_to_path(repository.title)
  end
  
  after_create do |repository|
    create_repository
  end
  
  before_destroy do |repository|
    destroy_repository
  end
  
  validate :validate_owner_existance
  VALID_TITLE_REGEX = /^[A-Za-z0-9_\.\-\ ]+$/
  validates :title, presence: true, length: { maximum: 32, minimum: 3 },
                    uniqueness: { case_sensitive: false }, format: VALID_TITLE_REGEX
  VALID_PATH_REGEX = /^[a-z0-9_\.\-]+$/
  validates :path, presence: true, uniqueness: { case_sensitive: true }, format: VALID_PATH_REGEX
  
  def to_param
    path
  end
  
  def validate_owner_existance
    return if owners && owners.size >= 1
    errors.add :owners, 'has no owner'
  end
  
  def autocomplete_value
    "#{title}"
  end
  
  def ssh_url
    Bringit::Application.config.ssh_base_url + path + ".git"
  end
  
  def local_path
    Bringit::Application.config.git_root + id.to_s + ".git"
  end
  
  def contributors
    owners
  end
  
  def self.title_to_path(title)
    title.downcase.tr('^a-z0-9', ' ').gsub(/\ /, '_')
  end
  
  def create_repository
    repo = Rugged::Repository.init_at(local_path, true)
  end
  
  def destroy_repository
    system "rm -rf #{local_path}"
  end
  
  def open_repo
    return if @repo.class == Rugged::Repository
    @repo = Rugged::Repository.new(local_path)
  rescue 
    raise RepositoryNotFoundError
  end
  
  def add_file(user, tmp_path, target_path, message)
    open_repo
    
    # Content
    file_content = File.open(tmp_path, 'rb').read
    
    blob_oid = Rugged::Blob.create(@repo, file_content)
    
    #Entry
    entry = {
      type: :blob, 
      name: target_path, 
      oid: blob_oid, 
      content: file_content,
      filemode: 33188
    }
    
    # Create Tree
    builder = Rugged::Tree::Builder.new
    unless @repo.empty?
      old_tree = @repo.lookup(@repo.head.target).tree
      old_tree.each do |old_entry|
        builder.insert(old_entry)
      end
    end
    builder.insert(entry)
    tree_oid = builder.write(@repo)
    
    # Created tree
    tree = @repo.lookup(tree_oid)
    
    # Commit Sha
    commit_oid = Rugged::Commit.create(@repo, author: user.author, 
      message: message, committer: user.author, parents: commit_parents, tree: tree)
    rugged_commit = @repo.lookup(commit_oid)
    
    if @repo.empty?
      ref = Rugged::Reference.create(@repo, 'refs/heads/master', commit_oid)
    else
      @repo.head.target = commit_oid
    end
    
    touch
    
    push = build_push(user)
    commit = build_commit(user, push, rugged_commit)
    commit.save
  end
  
  def commit_parents
    if @repo.empty?
      []
    else
      puts @repo.head.target
      [@repo.head.target]
    end
  end
  
  def build_commit(user, push, rugged_commit)
    Commit.new(author_email: rugged_commit.author[:email], author_name: rugged_commit.author[:name], author_time: rugged_commit.author[:time],
      committer_email: rugged_commit.committer[:email], committer_name: rugged_commit.committer[:name], committer_time: rugged_commit.committer[:time],
      push: push, commit_hash: rugged_commit.oid, message: rugged_commit.message, parents: get_parents(rugged_commit))
  end
  
  def build_push(user)
    Push.new(push_type: 'web', author: user, repository: self)
  end
  
  def get_parents(rugged_commit)
    if rugged_commit.parents.empty?
      []
    else
      Commit.identifiers(rugged_commit.parents.map { |c| c.oid }, self)
    end
  end
  
  def folder_contents_head(dir_path='')
    open_repo
    if !@repo.empty? && @repo.head && @repo.head.target
      folder_contents(@repo.head.target, dir_path)
    else
      []
    end
  end
  
  def path_exists_head?(url='')
    open_repo
    if !@repo.empty? && @repo.head && @repo.head.target
      path_exists?(@repo.head.target, url)
    else
      url == ''
    end
  end
  
  def path_exists?(commit_oid, url='')
    open_repo
    path_exists_rugged?(@repo.lookup(commit_oid), url)
  end
  
  def folder_contents(commit_oid, dir_path='')
    open_repo
    folder_contents_rugged(@repo.lookup(commit_oid), dir_path)
  end
  
  def folder_contents_rugged(rugged_commit, dir_path='')
    tree = get_object(rugged_commit, dir_path)
    
    contents = []
    
    if tree.type == :tree
      tree.each_tree do |subdir|
        path_file = dir_path.dup
        path_file << '/' unless dir_path.empty?
        path_file << subdir[:name]
        
        contents << {
          type: :dir,
          name: subdir[:name],
          path: path_file
        }
      end
      
      tree.each_blob do |file|
        path_file = dir_path.dup
        path_file << '/' unless dir_path.empty?
        path_file << file[:name]
  
        contents << {
          type: :file,
          name: file[:name],
          path: path_file
        }
      end
    end
    
    contents
  end
  
  # can throw error: Rugged::OdbError: Object not found - failed to find pack entry
  def get_object(rugged_commit, object_path='')
    object = rugged_commit.tree
    object_path.split('/').each do |part|
      object = @repo.lookup(object[part][:oid]) unless part.empty?
    end
    
    object
  end
  
  def path_exists_rugged?(rugged_commit, url='')
    if url.empty?
      true
    else
      tree = rugged_commit.tree
      get_object(rugged_commit, url)
      
      true
    end
  rescue Rugged::OdbError
    false
  end
  
  default_scope order: 'updated_at desc'
  scope :search, ->(term) { where "title LIKE ?", "%" << term << "%" }
  scope :identifier, ->(path) { where "path = ?", path }
  
  paginates_per 10
  max_paginates_per 50
end
