class GitRepository < ActiveRecord::Base
  attr_accessible :description, :path, :title
  
  validates :title, presence: true
  VALID_PATH_REGEX = /^([^\s\\\/\?\*\"\>\<\|\:][^\\\/\?\*\"\>\<\|\:]+[^\s\\\/\?\*\"\>\<\|\:]|[^\s\\\/\?\*\"\>\<\|\:])*(\/([^\s\\\/\?\*\"\>\<\|\:][^\\\/\?\*\"\>\<\|\:]+[^\s\\\/\?\*\"\>\<\|\:]|[^\s\\\/\?\*\"\>\<\|\:])*)*$/
  validates :path, presence: true, uniqueness: { case_sensitive: true }, format: VALID_PATH_REGEX
end
