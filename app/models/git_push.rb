class GitPush < ActiveRecord::Base
  attr_accessible :push_type, :author, :git_repository, :git_commits
  
  belongs_to :author, class_name: 'User'
  belongs_to :git_repository
  has_many :git_commits, class_name: 'GitCommit', foreign_key: 'git_push_id'
  
  validates :push_type, presence: true, included_in: ['web', 'ssh']
end
