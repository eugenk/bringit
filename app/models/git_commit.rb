class GitCommit < ActiveRecord::Base
  attr_accessible :author_email, :author_name, :author_time, :committer_email, :committer_name, 
    :committer_time, :git_push_id, :commit_hash, :message, :parents
  
  belongs_to :git_push
  has_one :git_repository, through: :git_push
  has_many :git_commit_links, foreign_key: 'child_id', class_name: 'GitCommitLink'
  has_many :parents, through: :git_commit_links
  
  VALID_HASH_REGEX = /^[0-9a-f]+$/i
  validates :commit_hash, presence: true, length: { maximum: 40, minimum: 40 }, format: VALID_HASH_REGEX
  validates :message, presence: true
  
  def add_parent(parent)
    return if parent == self || parents.include?(parent) 
    parents << parent
  end
end
