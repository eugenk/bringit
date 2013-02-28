module CommitsHelper
  
  def group_commits(commits)
    commits.group_by { |e| e.committer_time.strftime("%d.%m.%Y") }.map { |k, v| {commits: v, date: k} }
  end
  
  def get_branches(repository, current_commit)
    branches = repository.get_branches
    
    exists = false
    entries = []
    
    unless branches.empty?
      entries = branches.map do |b|
        # b[:name], #b[:oid], #b[:refname]
        exists ||= (current_commit && b[:oid] == current_commit.commit_hash)
        {
          url: browse_commits_root_path(repository.path, b[:oid]),
          name: b[:name],
          active: (current_commit && b[:oid] == current_commit.commit_hash)
        }
      end
    end
    
    entries.unshift({
      url: browse_commits_root_path(repository.path, current_commit.commit_hash),
      name: current_commit.short_hash,
      active: true
    }) unless exists || !current_commit
    
    entries
  end
  
end