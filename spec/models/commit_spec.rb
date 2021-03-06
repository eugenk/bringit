require 'spec_helper'

describe Commit do
  before do
    @commit = Commit.new(commit_hash: 'd430f8f9b7bdbd5c767904420bb3d3332d5a165a', 
                            message: 'Initialize repository')
  end
  
  subject { @commit }
  
  it { should be_valid }
  
  # responsiveness
  [:author_email, :author_name, :author_time, 
    :committer_email, :committer_name, :committer_time, 
    :push_id, :commit_hash, :message, :parents].each do |field|
    it { should respond_to(field) }
  end
  
  # presence
  [:commit_hash, :message].each do |field|
    describe "when #{field} is not present" do
      before { @commit[field] = " " }
      it { should_not be_valid }
    end
  end
  
  describe "when hash format is invalid" do
    before { @commit.commit_hash = 'g' * 40 }
    it { should_not be_valid }
  end
  
  describe "when hash is too short" do
    before { @commit.commit_hash = '0' * 39 }
    it { should_not be_valid }
  end
  
  describe "when hash is too long" do
    before { @commit.commit_hash = '0' * 41 }
    it { should_not be_valid }
  end
  
  describe "when it has a valid parent" do
    before do
      parent = @commit.dup
      parent.commit_hash.reverse!
      @commit.add_parent(parent)
    end
    it { should be_valid }
    
    it "should have one parent" do
      @commit.parents.size.should == 1
    end
  end
  
  describe "when it is its own parent" do
    before do
      @commit.add_parent(@commit)
    end
    it "should have no parent" do
      @commit.parents.size.should == 0
    end
  end
  
  describe "when it parent is added twice" do
    before do
      parent = @commit.dup
      parent.commit_hash.reverse!
      @commit.add_parent(parent)
      @commit.add_parent(parent)
    end
    
    describe "it should be valid" do
      it { should be_valid }
    end
    
    it "should have only one parent" do
      @commit.parents.size.should == 1
    end
  end
  
  it "when short hash is prefix of full hash" do
    @commit.short_hash.should == @commit.commit_hash[0..@commit.short_hash.size-1]
  end
  
  it "when short hash has size of 7" do
    @commit.short_hash.size.should == 7
  end
  
  it "when title returns only first line of message" do
    @commit.title.should == @commit.message.split('\n').first
  end
end
