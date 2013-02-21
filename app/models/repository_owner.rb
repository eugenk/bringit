class RepositoryOwner < ActiveRecord::Base
  belongs_to :repository
  belongs_to :owner, class_name: 'User'
  attr_accessible :repository, :owner
end
