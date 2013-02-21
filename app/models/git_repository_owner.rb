class GitRepositoryOwner < ActiveRecord::Base
  belongs_to :git_repository
  belongs_to :owner, class_name: 'User'
  attr_accessible :git_repository, :owner
end
