module CommitGettable
  extend ActiveSupport::Concern


  protected

  def get_commit(commit_oid=nil)
    if repo.empty?
      nil
    else
      repo.lookup(commit_oid || head_oid)
    end
  end
end