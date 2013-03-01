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
  
  paginates_per 10
  max_paginates_per 50
  
  default_scope order: 'committer_time desc, id desc'
  
  scope :identifiers, ->(oids, repository) do
    where("commit_hash IN (?)", oids).joins(:push).where("pushes.repository_id = ?", repository.id)
  end
  
  scope :identifier, ->(oid) do
    where("commit_hash = ?", oid)
  end
  
  
  def add_parent(parent)
    return if parent == self || parents.include?(parent) 
    parents << parent
  end
  
  def short_hash
    commit_hash[0..6]
  end
  
  def title
    Commit.message_title(message)
  end

  def body
    Commit.message_body(message)
  end
  
  def self.message_title(message)
    message.split('\n').first
  end
  
  def self.message_body(message)
    message.split("\n")[1..-1].join("\n")
  end
end
