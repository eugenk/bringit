require 'spec_helper'

describe Repository do
  before do
    system "rm -rf #{Bringit::Application.config.git_root}"
    system "mkdir -p #{Bringit::Application.config.git_root}"
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
  
  describe "should be valid after save" do
    before { @repository.save }
    it { should be_valid }
  end
  
  it "path is derived from title" do
    @repository.save
    @repository.path.should == 'bringit___git_web_interface'
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
      title_chars = %w[A B Z]
      titles = title_chars.map{ |s| "Bringit - g#{s}t web-interface" }
      titles.each do |t|
        @repository.title = t
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
  
  it "when repository is created in the filesystem" do
    @repository.save
    @repository.open_repo
    @repository.should be_valid
  end
  
  it "when repository is deleted from the filesystem" do
    expect do
      @repository.save
      @repository.destroy
      @repository.open_repo
    end.to raise_error(RepositoryNotFoundError)
  end
end
