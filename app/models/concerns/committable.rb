module Committable
  extend ActiveSupport::Concern
  
  def delete_file(user, target_path)
    commit_file(user, nil, target_path, "Delete file #{target_path}")
  end

  def add_file(user, tmp_path, target_path, message)
    commit_file(user, File.open(tmp_path, 'rb').read, target_path, message)
  end
  
  def commit_file(user, file_contents, target_path, message)
    #Entry
    entry = nil
    if file_contents
      entry = {
        type: :blob, 
        name: nil, 
        oid: Rugged::Blob.create(repo, file_contents), 
        content: file_contents,
        filemode: 33188
      }
    end
    
    # TreeBuilder
    if repo.empty?
      old_tree = nil
    else
      old_tree = head.tree 
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
    
    commit
  end
  
  
  protected
  
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
end