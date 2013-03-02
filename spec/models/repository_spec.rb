require 'spec_helper'

describe Repository do
  before do
    system "rm -rf #{Bringit::Application.config.git_root}"
    system "mkdir -p #{Bringit::Application.config.git_root}"
    @user = User.new(email: "user@example.com", 
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
    @repository.repo
    @repository.should be_valid
  end
  
  it "when repository is deleted from the filesystem" do
    expect do
      @repository.save
      @repository.destroy
      @repository.repo
    end.to raise_error(RepositoryNotFoundError)
  end
  
  describe "can commit a file" do
    before do
      @repository.save
      @repository.commit_file(@repository.owners.first, 'Some content', 'path/file.txt', 'Some commit message')
    end
    it { should be_valid }
    it "should exist a commit in the database" do
      @repository.commits.last.message.should == 'Some commit message'
    end
    it "should exist as head target" do
      @repository.path_exists?(nil, 'path/file.txt').should == true
    end
    it "should have the right name" do
      @repository.get_current_file(nil, 'path/file.txt')[:name].should == 'file.txt'
    end
    it "should have the right content" do
      @repository.get_current_file(nil, 'path/file.txt')[:content].should == 'Some content'
    end
    it "should have the right mime type" do
      @repository.get_current_file(nil, 'path/file.txt')[:mime_type].should == Mime::Type.lookup('text/plain')
    end
  end
  
  describe "can delete a file" do
    before do
      @repository.save
      @repository.commit_file(@repository.owners.first, 'Some content', 'path/file.txt', 'Some commit message')
      @repository.delete_file(@repository.owners.first, 'path/file.txt')
    end
    it "should exist a commit in the database" do
      @repository.all_commits.first.message.should == 'Delete file path/file.txt'
    end
    it "should not exist in repository" do
      @repository.path_exists?(nil, 'path/file.txt').should == false
    end
  end
  
  describe "can read a folder" do
    before do
      @repository.save
      @commit_add1 = @repository.commit_file(@repository.owners.first, 'Some content', 'path/file1.txt', 'Some commit message1')
      @commit_add2 = @repository.commit_file(@repository.owners.first, 'Some content', 'path/file2.txt', 'Some commit message2')
      @commit_add3 = @repository.commit_file(@repository.owners.first, 'Some content', 'file3.txt', 'Some commit message2')
      @commit_del1 = @repository.delete_file(@repository.owners.first, 'path/file1.txt')
      @commit_del2 = @repository.delete_file(@repository.owners.first, 'path/file2.txt')
      @commit_del3 = @repository.delete_file(@repository.owners.first, 'file3.txt')
    end

    
    it "should read the right number of contents in the root folder after adding the first file" do
      @repository.folder_contents(@commit_add1.commit_hash).size.should == 1
    end
    
    it "should read the right contents in the root folder after adding the first file" do
      @repository.folder_contents(@commit_add1.commit_hash).should == [{
        type: :dir,
        name: 'path',
        path: 'path'
      }]
    end
    
    it "should read the right number of contents in the subfolder after adding the first file" do
      @repository.folder_contents(@commit_add1.commit_hash, 'path').size.should == 1
    end
    
    it "should read the right contents in the subfolder after adding the first file" do
      @repository.folder_contents(@commit_add1.commit_hash, 'path').should == [{
        type: :file,
        name: 'file1.txt',
        path: 'path/file1.txt'
      }]
    end
    
    
    it "should read the right number of contents in the root folder after adding the second file" do
      @repository.folder_contents(@commit_add2.commit_hash).size.should == 1
    end
    
    it "should read the right contents in the root folder after adding the second file" do
      @repository.folder_contents(@commit_add2.commit_hash).should == [{
        type: :dir,
        name: 'path',
        path: 'path'
      }]
    end

    it "should read the right number of contents in the subfolder after adding the second file" do
      @repository.folder_contents(@commit_add2.commit_hash, 'path').size.should == 2
    end
    
    it "should read the right contents in the subfolder after adding the second file" do
      @repository.folder_contents(@commit_add2.commit_hash, 'path').should == [{
        type: :file,
        name: 'file1.txt',
        path: 'path/file1.txt'
      },{
        type: :file,
        name: 'file2.txt',
        path: 'path/file2.txt'
      }]
    end


    it "should read the right number of contents in the root folder after adding the third file" do
      @repository.folder_contents(@commit_add3.commit_hash).size.should == 2
    end
    
    it "should read the right contents in the root folder after adding the third file" do
      @repository.folder_contents(@commit_add3.commit_hash).should == [{
        type: :dir,
        name: 'path',
        path: 'path'
      },{
        type: :file,
        name: 'file3.txt',
        path: 'file3.txt'
      }]
    end

    it "should read the right number of contents in the root folder after adding the third file" do
      @repository.folder_contents(@commit_add3.commit_hash).size.should == 2
    end
    
    it "should read the right contents in the root folder after adding the third file" do
      @repository.folder_contents(@commit_add3.commit_hash).should == [{
        type: :dir,
        name: 'path',
        path: 'path'
      },{
        type: :file,
        name: 'file3.txt',
        path: 'file3.txt'
      }]
    end

    it "should read the right number of contents in the subfolder after adding the third file" do
      @repository.folder_contents(@commit_add3.commit_hash, 'path').size.should == 2
    end
    
    it "should read the right contents in the subfolder after adding the third file" do
      @repository.folder_contents(@commit_add3.commit_hash, 'path').should == [{
        type: :file,
        name: 'file1.txt',
        path: 'path/file1.txt'
      },{
        type: :file,
        name: 'file2.txt',
        path: 'path/file2.txt'
      }]
    end
    
    
    it "should read the right number of contents in the root folder after deleting the first file" do
      @repository.folder_contents(@commit_del1.commit_hash).size.should == 2
    end
    
    it "should read the right contents in the root folder after deleting the first file" do
      @repository.folder_contents(@commit_del1.commit_hash).should == [{
        type: :dir,
        name: 'path',
        path: 'path'
      },{
        type: :file,
        name: 'file3.txt',
        path: 'file3.txt'
      }]
    end
    
    it "should read the right number of contents in the subfolder after deleting the first file" do
      @repository.folder_contents(@commit_del1.commit_hash, 'path').size.should == 1
    end
    
    it "should read the right contents in the subfolder after deleting the first file" do
      @repository.folder_contents(@commit_del1.commit_hash, 'path').should == [{
        type: :file,
        name: 'file2.txt',
        path: 'path/file2.txt'
      }]
    end
    
    
    it "should read the right number of contents in the root folder after deleting the second file" do
      @repository.folder_contents(@commit_del2.commit_hash).size.should == 1
    end
    
    it "should read the right contents in the root folder after deleting the second file" do
      @repository.folder_contents(@commit_del2.commit_hash).should == [{
        type: :file,
        name: 'file3.txt',
        path: 'file3.txt'
      }]
    end
    
    
    it "should read the right number of contents in the root folder after deleting the third file" do
      @repository.folder_contents(@commit_del3.commit_hash).size.should == 0
    end
    
    it "should read the right contents in the root folder after deleting the third file" do
      @repository.folder_contents(@commit_del3.commit_hash).should == []
    end
  end
  
  describe "can overwrite file" do
    before do
      @repository.save
      @repository.commit_file(@repository.owners.first, 'Some content', 'path/file.txt', 'Some commit message')
      @repository.commit_file(@repository.owners.first, 'Some content2', 'path/file.txt', 'Some commit message2')
    end
    it "should exist commit in the database" do
      @repository.all_commits.first.message.should == 'Some commit message2'
    end
    it "should have the right name" do
      @repository.get_current_file(nil, 'path/file.txt')[:name].should == 'file.txt'
    end
    it "should have the right content" do
      @repository.get_current_file(nil, 'path/file.txt')[:content].should == 'Some content2'
    end
  end
end
