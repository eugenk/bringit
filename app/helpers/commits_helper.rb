module CommitsHelper
  
  def group_commits(commits)
    commits.group_by { |e| e.committer_time.strftime("%d.%m.%Y") }.map { |k, v| {commits: v, date: k} }
  end
  
  def get_branches(repository, current_commit)
    branches = repository.get_branches
    
    exists = false
    entries = []
    
    if branches.empty?
      entries.unshift({
        url: repository_path(repository.path),
        name: 'master',
        active: false
      })
    else
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
  
  def get_message(current_commit)
    title = word_wrap(current_commit.title, line_width: 80)
    body = current_commit.body
    if title != current_commit.title
      parts = title.split("\n")
      title = "#{parts[0]}..."
      body = "#{parts[1..-1].join("\n")}\n#{body}"
    end
    
    {
      title: title,
      body: body
    }
    
  end
  
end