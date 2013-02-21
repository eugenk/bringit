class Commit < ActiveRecord::Base
  attr_accessible :author_email, :author_name, :author_time, :committer_email, :committer_name, 
    :committer_time, :push_id, :commit_hash, :message, :parents, :push
  
  belongs_to :push
  has_one :repository, through: :push
  has_many :commit_links, foreign_key: 'child_id', class_name: 'CommitLink'
  has_many :parents, through: :commit_links
  
  VALID_HASH_REGEX = /^[0-9a-f]+$/i
  validates :commit_hash, presence: true, length: { maximum: 40, minimum: 40 }, format: VALID_HASH_REGEX
  validates :message, presence: true
  
  default_scope order: 'committer_time desc'
  
  def add_parent(parent)
    return if parent == self || parents.include?(parent) 
    parents << parent
  end
  
  def short_hash
    commit_hash[0..6]
  end
  
  def message_title
    message.split('\n').first
  end
end
