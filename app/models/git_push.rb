class GitPush < ActiveRecord::Base
  belongs_to :author
  attr_accessible :push_type
end
