class GitCommitLink < ActiveRecord::Base
  belongs_to :parent
  belongs_to :child
  # attr_accessible :title, :body
end
