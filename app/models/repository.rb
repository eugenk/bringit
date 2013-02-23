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
    @repo = Rugged::Repository.new(local_path)
  #rescue 
    #raise RepositoryNotFoundError
  end
  
  def add_commit(user, tmp_path, target_path, message)
    open_repo unless @repo.class == Rugged::Repository
    
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
      old_tree.each_tree do |old_entry|
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
    commit = @repo.lookup(commit_oid)
    
    if @repo.empty?
      ref = Rugged::Reference.create(@repo, 'refs/heads/master', commit_oid)
    else
      @repo.head.target = commit_oid
    end
    
    
    save
  end
  
  def commit_parents
    if @repo.empty?
      []
    else
      puts @repo.head.target
      [@repo.head.target]
    end
  end
  
  default_scope order: 'updated_at desc'
  scope :search, ->(term) { where "title LIKE ?", "%" << term << "%" }
  scope :identifier, ->(path) { where "path = ?", path }
  
  paginates_per 10
  max_paginates_per 50
end
