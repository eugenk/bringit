require 'spec_helper'

describe GitCommitLink do
  before do
    @commit1 = GitCommit.new(commit_hash: 'd430f8f9b7bdbd5c767904420bb3d3332d5a165a', 
                             message: 'Initialize repository')
    @commit2 = @commit1.dup
    @commit2.commit_hash = '0' * 40
    @commit_link = GitCommitLink.new(parent: @commit1, child: @commit2)
  end
  
  subject { @commit_link }
  
  it { should be_valid }
  
  # responsiveness
  [:parent, :child].each do |field|
    it { should respond_to(field) }
  end
  
  # presence
  [:parent, :child].each do |field|
    describe "when #{field} is not present" do
      before { @commit_link[field] = " " }
      it { should_not be_valid }
    end
  end
  
  describe "when link is already taken" do
    before do
      @commit1.save
      @commit2.save
      commit_link2 = @commit_link.dup
      commit_link2.save
    end
    it { should_not be_valid }
  end
  
  describe "when the links are cyclic" do
    before do
      @commit1.save
      @commit2.save
      commit_link2 = @commit_link.dup
      commit_link2.parent = @commit_link.child
      commit_link2.child = @commit_link.parent
      commit_link2.save
    end
    it { should_not be_valid }
  end
end
