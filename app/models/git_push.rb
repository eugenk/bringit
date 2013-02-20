class GitPush < ActiveRecord::Base
  belongs_to :author, class_name: 'User'
  
  attr_accessible :push_type, :author
  
  validates :push_type, presence: true, include: ['web', 'ssh']
end
