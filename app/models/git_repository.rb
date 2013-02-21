class GitRepository < ActiveRecord::Base
  attr_accessible :description, :path, :title
  
  validates :title, presence: true
  VALID_PATH_REGEX = /^((?:[a-zA-Z0-9]+(?:_[a-zA-Z0-9]+)*(?:\-[a-zA-Z0-9]+)*)+)$/
  validates :path, presence: true, uniqueness: { case_sensitive: true }, format: VALID_PATH_REGEX
end
