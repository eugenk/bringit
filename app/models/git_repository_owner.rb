class GitRepositoryOwner < ActiveRecord::Base
  belongs_to :git_repository
  belongs_to :owner
  # attr_accessible :title, :body
end