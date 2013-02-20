require 'spec_helper'

describe GitRepositoryOwner do
  before do
    @respository = GitRepository.new(path: 'some/path/bringit.git', title: 'bringit!')
    @user = User.new(email: "eugenk@tzi.de", 
                     password: "password", password_confirmation: "password")
    @repository_owner = GitRepositoryOwner.new(git_repository: @repository, owner: @user)
  end
  
  subject { @repository_owner }
  
  it { should be_valid }
  
  # responsiveness
  [:git_repository, :owner].each do |field|
    it { should respond_to(field) }
  end
  
  # presence
  [:git_repository, :owner].each do |field|
    describe "when #{field} is not present" do
      before { @repository_owner[field] = " " }
      it { should_not be_valid }
    end
  end
  
  describe "when link is already taken" do
    before do
      @commit1.save
      @commit2.save
      repository_owner2 = @repository_owner.dup
      repository_owner2.save
    end
    it { should_not be_valid }
  end
  
  describe "when the links are cyclic" do
    before do
      @commit1.save
      @commit2.save
      repository_owner2 = @repository_owner.dup
      repository_owner2.parent = @repository_owner.child
      repository_owner2.child = @repository_owner.parent
      repository_owner2.save
    end
    it { should_not be_valid }
  end
end
