module CommitsHelper
  
  def group_commits(commits)
    commits.group_by { |e| e.committer_time.strftime("%d.%m.%Y") }.map { |k, v| {commits: v, date: k} }
  end
  
end