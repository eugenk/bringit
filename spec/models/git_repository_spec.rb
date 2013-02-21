require 'spec_helper'

describe GitRepository do
  before do
    @user = User.new(email: "eugenk@tzi.de", 
                     password: "password", password_confirmation: "password")
    @repository = GitRepository.new(path: 'some/path/bringit.git', title: 'bringit!', owners: [@user])
    @fields = [:path, :title, :description]
  end
  
  subject { @repository }
  
  it { should be_valid }
  
  # responsiveness
  [:path, :title, :description, :owners].each do |field|
    it { should respond_to(field) }
  end
  
  # presence
  [:path, :title].each do |field|
    describe "when #{field} is not present" do
      before { @repository[field] = " " }
      it { should_not be_valid }
    end
  end
  
  describe "when path is already taken" do
    before do
      entry1 = @repository.dup
      entry1.owners = [@user]
      entry1.save
    end
    it { should_not be_valid }
  end
  
  describe "when path has invalid format" do
    it "should be invalid" do
      bad_sequences = %w[\ // : ? * " > < |].concat [" /", "/ "]
      paths = bad_sequences.map{ |s| "some#{s}invalidpath" }
      paths.each do |invalid_path|
        @repository.path = invalid_path
        @repository.should_not be_valid
      end
    end
  end
  
  describe "when it has no owner" do
    before do
      @repository.owners -= [@user]
    end
    it { should_not be_valid }
  end
  
end