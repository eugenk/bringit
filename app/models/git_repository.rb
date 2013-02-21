class GitRepository < ActiveRecord::Base
  attr_accessible :description, :path, :title, :owners
  
  has_many :git_repository_owners, foreign_key: 'git_repository_id', class_name: 'GitRepositoryOwner'
  has_many :owners, through: :git_repository_owners, class_name: 'User'
  
  validate :validate_owner_existance
  validates :title, presence: true
  VALID_PATH_REGEX = /^([^\s\\\/\?\*\"\>\<\|\:][^\\\/\?\*\"\>\<\|\:]+[^\s\\\/\?\*\"\>\<\|\:]|[^\s\\\/\?\*\"\>\<\|\:])*(\/([^\s\\\/\?\*\"\>\<\|\:][^\\\/\?\*\"\>\<\|\:]+[^\s\\\/\?\*\"\>\<\|\:]|[^\s\\\/\?\*\"\>\<\|\:])*)*$/
  validates :path, presence: true, uniqueness: { case_sensitive: true }, format: VALID_PATH_REGEX
  
  def validate_owner_existance
    return if owners && owners.size >= 1
    errors.add :owners, 'has no owner'
  end
end
