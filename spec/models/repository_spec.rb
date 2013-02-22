require 'spec_helper'

describe Repository do
  before do
    @user = User.new(email: "eugenk@tzi.de", 
                     password: "password", password_confirmation: "password")
    @repository = Repository.new(title: 'Bringit - git web-interface', owners: [@user])
    @fields = [:path, :title, :description]
  end
  
  subject { @repository }
  
  it { should be_valid }
  
  # responsiveness
  [:path, :title, :description, :owners].each do |field|
    it { should respond_to(field) }
  end
  
  # presence
  [:title].each do |field|
    describe "when #{field} is not present" do
      before { @repository[field] = " " }
      it { should_not be_valid }
    end
  end
  
  it "path is derived from title" do
    @repository.save
    @repository.path.should == 'bringit_git_web_interface'
  end
  
  describe "when path is already taken" do
    before do
      entry1 = @repository.dup
      entry1.owners = [@user]
      entry1.save
    end
    it { should_not be_valid }
  end
  
  describe "when title has characters that are not allowed in the path" do
    it "should be valid" do
      title_chars = %w[A B Z a b z 0 1 9 _ . -].push(' ')
      titles = title_chars.map{ |s| "some#{s}title" }
      titles.each do |t|
        @repository.title = t
        @repository.save
        @repository.should be_valid
      end
    end
  end
  
  describe "when title is too short" do
    before { @repository.title = 'a'*2 }
    it { should_not be_valid }
  end
  
  describe "when title is too long" do
    before { @repository.title = 'a'*33 }
    it { should_not be_valid }
  end
  
  describe "when it has no owner" do
    before do
      @repository.owners -= [@user]
    end
    it { should_not be_valid }
  end
  
  it "when ssh_url is derived from path and config" do
    @repository.save
    @repository.ssh_url.should == Bringit::Application.config.ssh_base_url + @repository.path + ".git"
  end
end