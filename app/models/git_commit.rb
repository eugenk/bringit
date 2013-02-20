class GitCommit < ActiveRecord::Base
  attr_accessible :author_email, :author_name, :author_time, :committer_email, :committer_name, 
    :committer_time, :git_push_id, :commit_hash, :message
  
  belongs_to :git_push
  has_one :git_repository, through: :git_push
  
  VALID_HASH_REGEX = /^[0-9a-f]+$/i
  validates :commit_hash, presence: true, length: { maximum: 40, minimum: 40 }, format: VALID_HASH_REGEX
  validates :message, presence: true
end
