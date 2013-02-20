class GitRepository < ActiveRecord::Base
  attr_accessible :description, :path, :title
end
