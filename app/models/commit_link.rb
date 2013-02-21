class CommitLink < ActiveRecord::Base
  belongs_to :parent, class_name: 'Commit'
  belongs_to :child, class_name: 'Commit'
  attr_accessible :parent, :child, :parent_id, :child_id
  
  validates_uniqueness_of :parent_id, :scope => :child_id
end
