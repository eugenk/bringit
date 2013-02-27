class Push < ActiveRecord::Base
  attr_accessible :push_type, :author, :repository, :commits
  
  belongs_to :author, class_name: 'User'
  belongs_to :repository
  has_many :commits
  
  validates_inclusion_of :push_type, in: ['web', 'ssh']
end
