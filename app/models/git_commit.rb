class GitCommit < ActiveRecord::Base
  attr_accessible :author_email, :author_name, :author_time, :committer_email, :committer_name, :committer_time, :git_push_id, :hash, :message
end
