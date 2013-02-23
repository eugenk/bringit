class Repository < ActiveRecord::Base
  attr_accessible :description, :path, :title, :owners, :pushes, :commits
  
  has_many :repository_owners, foreign_key: 'repository_id', class_name: 'RepositoryOwner'
  has_many :owners, through: :repository_owners, class_name: 'User'
  has_many :pushes, class_name: 'Push', foreign_key: 'repository_id'
  has_many :commits, class_name: 'Commit', through: :pushes, :limit => 3
  
  before_validation do |repository|
    return unless repository.title
    repository.path = Repository.title_to_path(repository.title)
  end
  
  before_create do |repository|
    create_repository
  end
  
  validate :validate_owner_existance
  VALID_TITLE_REGEX = /^[A-Za-z0-9_\.\-\ ]+$/
  validates :title, presence: true, length: { maximum: 32, minimum: 3 },
                    uniqueness: { case_sensitive: false }, format: VALID_TITLE_REGEX
  VALID_PATH_REGEX = /^[a-z0-9_\.\-]+$/
  validates :path, presence: true, uniqueness: { case_sensitive: true }, format: VALID_PATH_REGEX
  
  def validate_owner_existance
    return if owners && owners.size >= 1
    errors.add :owners, 'has no owner'
  end
  
  def autocomplete_value
    "#{title}"
  end
  
  def ssh_url
    Bringit::Application.config.ssh_base_url + path + ".git"
  end
  
  def local_path
    Bringit::Application.config.git_root + id + ".git"
  end
  
  def contributors
    owners
  end
  
  def self.title_to_path(title)
    title.downcase.tr('^a-z0-9', ' ').gsub(/\ /, '_')
  end
  
  def create_repository
    repo = Rugged::Repository.init_at(local_path, true)
  end
  
  def delete_repository
    system "rm -rf #{local_path}"
  end
  
  default_scope order: 'updated_at desc'
  scope :search, ->(term) { where "title LIKE ?", "%" << term << "%" }
  scope :identifier, ->(path) { where "path = ?", path }
  
  paginates_per 10
  max_paginates_per 50
end
