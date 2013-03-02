require 'digest/sha1'

class Repository < ActiveRecord::Base
  include CommitGettable, ObjectGettable, FolderContentsGettable, Committable
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

  def entries_info(commit_oid=nil, url_path='')
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit && url_path.empty?
      []
    else
      contents = folder_contents_rugged(rugged_commit, url_path)
      contents.map do |e|
        file_path = build_target_path(url_path, e[:name])
        entry_info_rugged(rugged_commit, file_path)
      end
    end
  end

  def entry_info(url, commit_oid=nil)
    rugged_commit = get_commit(commit_oid)
    entry_info_rugged(get_commit(commit_oid), url)
  end
  
  def entry_info_list(url, commit_oid=nil)
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit
      []
    else
      entry_info_list_rugged(rugged_commit, url)
    end
  end

  def get_changed_files(commit_oid=nil)
    rugged_commit = get_commit(commit_oid)
    if !rugged_commit
      []
    else
      get_changed_files_rugged(rugged_commit)
    end
  end
  
  # PROTECTED METHODS

  protected

  def entry_info_rugged(rugged_commit, url)
    object = get_object(rugged_commit, url)
    changing_rugged_commit = get_commit_of_last_change(url, object.oid, rugged_commit)
    build_entry_info(changing_rugged_commit, url)
  end
  
  def build_entry_info(changing_rugged_commit, url)
    {
      committer_name: changing_rugged_commit.committer[:name],
      committer_email: changing_rugged_commit.committer[:email],
      committer_time: changing_rugged_commit.committer[:time].iso8601,
      message: Commit.message_title(changing_rugged_commit.message),
      oid: changing_rugged_commit.oid,
      filename: url.split('/')[-1]
    }
  end
  
  def entry_info_list_rugged(rugged_commit, url)
    entries = []
    
    changing_rugged_commit = get_commit_of_last_change(url, nil, rugged_commit)
    previous_rugged_commit = nil
    
    until changing_rugged_commit == previous_rugged_commit || !changing_rugged_commit do
      entries << changing_rugged_commit.oid
      
      previous_rugged_commit = changing_rugged_commit
      
      unless changing_rugged_commit.parents.empty?
        changing_rugged_commit = get_commit_of_last_change(url, nil, changing_rugged_commit.parents.first)
      end
    end
    
    # file does not exist in inital commit
    if changing_rugged_commit && !path_exists_rugged?(changing_rugged_commit, url)
      entries[0..-2]
    else
      entries
    end
  end

  def get_changed_files_rugged(rugged_commit)
    if rugged_commit.parents.empty?
      get_changed_files_contents(rugged_commit.tree, {})
    else
      changed_files_infos = rugged_commit.parents.map do |p|
        get_changed_files_contents(rugged_commit.tree, p.tree)
      end

      changed_files_infos.flatten
    end
  end

  def get_changed_files_contents(current_tree, parent_tree, directory='')
    files_contents = []
    files_contents.concat(get_changed_files_contents_subtrees(current_tree, parent_tree, directory))
    files_contents.concat(get_changed_files_contents_current_tree(current_tree, parent_tree, directory))


    files_contents
  end

  def get_changed_files_contents_subtrees(current_tree, parent_tree, directory)
    files_contents = []
    files_contents.concat(get_changed_files_contents_subtrees_addeed_and_changed(current_tree, parent_tree, directory))
    files_contents.concat(get_changed_files_contents_subtrees_deleted(current_tree, parent_tree, directory))

    files_contents
  end

  def get_changed_files_contents_subtrees_addeed_and_changed(current_tree, parent_tree, directory)
    files_contents = []
    current_tree.each do |e|
      if e[:type] == :tree
        if parent_tree[e[:name]] && e[:oid] != parent_tree[e[:name]][:oid]
          files_contents.concat(get_changed_files_contents(repo.lookup(e[:oid]), repo.lookup(parent_tree[e[:name]][:oid]), "#{directory}#{e[:name]}/"))
        elsif !parent_tree[e[:name]]
          files_contents.concat(get_changed_files_contents(repo.lookup(e[:oid]), {}, "#{directory}#{e[:name]}/"))
        elsif parent_tree == {} || parent_tree.count == 0
          files_contents.concat(get_changed_files_contents(repo.lookup(e[:oid]), parent_tree, "#{directory}#{e[:name]}/"))
        end
      end
    end

    files_contents
  end

  def get_changed_files_contents_subtrees_deleted(current_tree, parent_tree, directory)
    files_contents = []
    parent_tree.each do |e|
      if e[:type] == :tree && !current_tree[e[:name]]
        files_contents.concat(get_changed_files_contents({}, repo.lookup(e[:oid]), "#{directory}#{e[:name]}/"))
      end
    end

    files_contents
  end

  def get_changed_files_contents_current_tree(current_tree, parent_tree, directory)
    files_contents = []
    files_contents.concat(get_changed_files_contents_current_tree_added_and_changed(current_tree, parent_tree, directory))
    files_contents.concat(get_changed_files_contents_current_tree_deleted(current_tree, parent_tree, directory))

    files_contents
  end

  def get_changed_files_contents_current_tree_added_and_changed(current_tree, parent_tree, directory)
    files_contents = []
    current_tree.each do |e|
      if e[:type] == :blob
        if parent_tree[e[:name]] && e[:oid] != parent_tree[e[:name]][:oid]
          files_contents << changed_files_entry(directory, e[:name], :change, repo.lookup(e[:oid]).content, repo.lookup(parent_tree[e[:name]][:oid]).content)
        elsif !parent_tree[e[:name]]
          files_contents << changed_files_entry(directory, e[:name], :add, repo.lookup(e[:oid]).content, '')
        end
      end
    end

    files_contents
  end

  def get_changed_files_contents_current_tree_deleted(current_tree, parent_tree, directory)
    files_contents = []
    parent_tree.each do |e|
      if e[:type] == :blob && !current_tree[e[:name]]
        files_contents << changed_files_entry(directory, e[:name], :delete, '', '')
      end
    end

    files_contents
  end

  def changed_files_entry(directory, name, type, content_current, content_parent)
    mime_info = mime_info(name)
    editable = mime_type_editable?(mime_info[:mime_type])
    {
      name: name,
      path: "#{directory}#{name}",
      diff: editable ? diff(content_current, content_parent) : '',
      type: type,
      mime_type: mime_info[:mime_type],
      mime_category: mime_info[:mime_category],
      editable: editable
    }
  end


  def diff(current, original)
    Diffy::Diff.new(original.force_encoding('UTF-8'), current.force_encoding('UTF-8'), include_plus_and_minus_in_html: true, context: 3, include_diff_info: true).to_s(:html)
  end

  def mime_info(filename)
    ext = File.extname(filename)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(ext) || Mime::TEXT
    mime_category = mime_type.to_s.split('/')[0]
    
    {
      mime_type: mime_type,
      mime_category: mime_category
    }
  end

  def mime_type_editable?(mime_type)
    mime_type.to_s == 'application/xml' || mime_type.to_s.match(/^text\/.*/)
  end
  
  def get_commit_of_last_change(url, previous_entry_oid=nil, rugged_commit=nil, previous_rugged_commit=nil)
    rugged_commit ||= head

    object = get_object(rugged_commit, url)
    object_oid = object ? object.oid : nil
    
    previous_entry_oid ||= object_oid unless previous_rugged_commit
    
    if object_oid == previous_entry_oid
      if rugged_commit.parents.empty?
        rugged_commit
      else
        parents = rugged_commit.parents.sort_by do |p|
          get_commit_of_last_change(url, previous_entry_oid, p, rugged_commit).committer[:time]
        end
        get_commit_of_last_change(url, previous_entry_oid, parents[-1], rugged_commit)
      end
    else
      previous_rugged_commit
    end
  end

  def get_commit(commit_oid=nil)
    if repo.empty?
      nil
    else
      repo.lookup(commit_oid || head_oid)
    end
  end
  
  def commit_parents
    if repo.empty?
      []
    else
      [head_oid]
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
      commits.identifiers(rugged_commit.parents.map { |c| c.oid }, self)
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

  def head_oid
    repo.head.target
  end

  def head
    repo.lookup(head_oid)
  end
end
