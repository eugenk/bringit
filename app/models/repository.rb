require 'digest/sha1'

class Repository < ActiveRecord::Base
  attr_accessible :description, :title, :owners
  attr_protected :path, :pushes, :commits, :repo
  
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
  
  def validate_owner_existance
    return if owners && owners.size >= 1
    errors.add :owners, 'has no owner'
  end
  
  def to_param
    path
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
  
  def repo
    @repo ||= Rugged::Repository.new(local_path)
  rescue 
    raise RepositoryNotFoundError
  end
  
  def build_tree(entry, tree, path_parts)
    builder = Rugged::Tree::Builder.new
    
    if tree
      old_entry = nil
      
      tree.each do |e|
        builder.insert(e)
        old_entry = e if e[:name] == path_parts.first
      end
      
      if old_entry
        if old_entry[:type] == :tree
          build_tree_tree(builder, entry, repo.lookup(old_entry[:oid]), path_parts)
        else
          build_tree_blob(builder, entry, path_parts)
        end
      else
        if path_parts.size == 1
          build_tree_blob(builder, entry, path_parts)
        else
          build_tree_tree(builder, entry, nil, path_parts)
        end    
      end
      
    elsif path_parts.size == 1
      build_tree_blob(builder, entry, path_parts)
    else
      build_tree_tree(builder, entry, nil, path_parts)
    end
    builder.reject! do |e|
      e[:type] == :tree && repo.lookup(e[:oid]).count == 0
    end
    tree_oid = builder.write(repo)
    
    repo.lookup(tree_oid)
  end
  
  def build_tree_tree(builder, entry, old_entry, path_parts)
    new_tree = build_tree(entry, old_entry, path_parts[1..-1])
    tree_entry = {
      type: :tree, 
      name: path_parts.first, 
      oid: new_tree.oid, 
      filemode: 16384
    }
    builder.insert(tree_entry)
  end
  
  def build_tree_blob(builder, entry, path_parts)
    if entry
      entry[:name] = path_parts.first
      builder.insert(entry)
    else
      builder.reject! { |e| e[:name] == path_parts.first }
    end
  end
  
  def delete_file(user, target_path)
    add_file(user, nil, target_path, "Delete file #{target_path}")
  end
  
  def add_file(user, tmp_path, target_path, message)
    #Entry
    entry = nil
    if tmp_path
      file_content = File.open(tmp_path, 'rb').read
      entry = {
        type: :blob, 
        name: nil, 
        oid: Rugged::Blob.create(repo, file_content), 
        content: file_content,
        filemode: 33188
      }
    end
    
    # TreeBuilder
    if repo.empty?
      old_tree = nil
    else
      old_tree = repo.lookup(repo.head.target).tree 
    end
    
    tree = build_tree(entry, old_tree, target_path.split('/'))
    
    # Commit Sha
    commit_oid = Rugged::Commit.create(repo, author: user.author, 
      message: message, committer: user.author, parents: commit_parents, tree: tree)
    rugged_commit = repo.lookup(commit_oid)
    
    if repo.empty?
      ref = Rugged::Reference.create(repo, 'refs/heads/master', commit_oid)
    else
      repo.head.target = commit_oid
    end
    
    touch
    
    push = build_push(user)
    commit = build_commit(user, push, rugged_commit)
    commit.save
  end
  
  def commit_parents
    if repo.empty?
      []
    else
      [repo.head.target]
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
  
  def path_exists_head?(url='')
    if !repo.empty? && repo.head && repo.head.target
      path_exists?(repo.head.target, url)
    else
      url == ''
    end
  end
  
  def path_exists?(commit_oid, url='')
    path_exists_rugged?(repo.lookup(commit_oid), url)
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
  
  def folder_contents_head(dir_path='')
    if !repo.empty? && repo.head && repo.head.target
      folder_contents(repo.head.target, dir_path)
    else
      []
    end
  end
  
  def folder_contents(commit_oid, dir_path='')
    folder_contents_rugged(repo.lookup(commit_oid), dir_path)
  end
  
  def folder_contents_rugged(rugged_commit, dir_path='')
    return [] unless path_exists_rugged?(rugged_commit, dir_path)
    
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
          path: path_file,
          size: nil
        }
      end
      
      tree.each_blob do |file|
        path_file = dir_path.dup
        path_file << '/' unless dir_path.empty?
        path_file << file[:name]
  
        contents << {
          type: :file,
          name: file[:name],
          path: path_file,
          size: file[:size]
        }
      end
    end
    
    contents
  end
  
  def get_current_file_head(url='')
    if !repo.empty? && repo.head && repo.head.target
      get_current_file(repo.head.target, url)
    else
      nil
    end
  end
  
  def get_current_file(commit_oid, url='')
    get_current_file_rugged(repo.lookup(commit_oid), url)
  end
  
  
  def get_current_file_rugged(rugged_commit, url='')
    return nil unless path_exists_rugged?(rugged_commit, url)
    
    object = get_object(rugged_commit, url)
    
    if object.type == :blob
      filename = url.split('/')[-1]
      ext = File.extname(filename)[1..-1]
      mime_type = Mime::Type.lookup_by_extension(ext) || Mime::TEXT
      mime_category = mime_type.to_s.split('/')[0]
      {
        name: filename,
        size: object.size,
        content: object.content,
        mime_type: mime_type,
        mime_category: mime_category
      }
    else
      nil
    end
  end
  
  # can throw error: Rugged::OdbError: Object not found - failed to find pack entry
  def get_object(rugged_commit, object_path='')
    object = rugged_commit.tree
    object_path.split('/').each do |part|
      return nil unless object[part]
      object = repo.lookup(object[part][:oid]) unless part.empty?
    end
    
    object
  end
  
  default_scope order: 'updated_at desc'
  scope :search, ->(term) { where "title LIKE ?", "%" << term << "%" }
  scope :identifier, ->(path) { where "path = ?", path }
  
  paginates_per 10
  max_paginates_per 50
end
