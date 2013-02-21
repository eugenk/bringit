class Repository < ActiveRecord::Base
  attr_accessible :description, :path, :title, :owners, :pushes, :commits
  
  has_many :repository_owners, foreign_key: 'repository_id', class_name: 'RepositoryOwner'
  has_many :owners, through: :repository_owners, class_name: 'User'
  has_many :pushes, class_name: 'Push', foreign_key: 'repository_id'
  has_many :commits, class_name: 'Commit', through: :pushes, :limit => 3
  
  validate :validate_owner_existance
  validates :title, presence: true
  VALID_PATH_REGEX = /^([^\s\\\/\?\*\"\>\<\|\:][^\\\/\?\*\"\>\<\|\:]+[^\s\\\/\?\*\"\>\<\|\:]|[^\s\\\/\?\*\"\>\<\|\:])*(\/([^\s\\\/\?\*\"\>\<\|\:][^\\\/\?\*\"\>\<\|\:]+[^\s\\\/\?\*\"\>\<\|\:]|[^\s\\\/\?\*\"\>\<\|\:])*)*$/
  validates :path, presence: true, uniqueness: { case_sensitive: true }, format: VALID_PATH_REGEX
  
  def validate_owner_existance
    return if owners && owners.size >= 1
    errors.add :owners, 'has no owner'
  end
  
  default_scope order: 'updated_at desc'
  
  paginates_per 10
  max_paginates_per 50
end
