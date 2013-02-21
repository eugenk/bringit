class Push < ActiveRecord::Base
  attr_accessible :push_type, :author, :repository, :commits
  
  belongs_to :author, class_name: 'User'
  belongs_to :repository
  has_many :commits, class_name: 'Commit', foreign_key: 'push_id'
  
  validates :push_type, presence: true, included_in: ['web', 'ssh']
end
