class GitPush < ActiveRecord::Base
  belongs_to :author, class_name: 'User'
  belongs_to :git_repository
  attr_accessible :push_type, :author, :git_repository
  
  validates :push_type, presence: true, included_in: ['web', 'ssh']
end
