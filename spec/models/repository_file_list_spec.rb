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

  describe "when getting the list of changed files" do
    before do
      @repository.save
      @content1 = "Some\ncontent\nwith\nmany\nlines."
      @content2 = "Some\ncontent,\nwith\nmany\nlines."
      @commit1 = @repository.commit_file(@repository.owners.first, @content1, 'path/to/file.xml', 'Message1')
      @commit2 = @repository.commit_file(@repository.owners.first, @content2, 'path/to/file.xml', 'Message2')
      @commit3 = @repository.delete_file(@repository.owners.first, 'path/to/file.xml')
    end
    
    it "last commit should be HEAD" do
      @repository.is_head?(@commit3.commit_hash).should == true
    end
    

    it "should have the right file count when using the first commit" do
      @repository.get_changed_files(@commit1.commit_hash).size.should == 1
    end
    
    it "should have the right name in the list when using the first commit" do
      @repository.get_changed_files(@commit1.commit_hash).first[:name].should == 'file.xml'
    end
    
    it "should have the right path in the list when using the first commit" do
      @repository.get_changed_files(@commit1.commit_hash).first[:path].should == 'path/to/file.xml'
    end
    
    it "should have the right type in the list when using the first commit" do
      @repository.get_changed_files(@commit1.commit_hash).first[:type].should == :add
    end
    
    it "should have the right mime type in the list when using the first commit" do
      @repository.get_changed_files(@commit1.commit_hash).first[:mime_type].should == Mime::Type.lookup_by_extension('xml')
    end
    
    it "should have the right mime category in the list when using the first commit" do
      @repository.get_changed_files(@commit1.commit_hash).first[:mime_category].should == 'application'
    end
    
    it "should have the right editable in the list when using the first commit" do
      @repository.get_changed_files(@commit1.commit_hash).first[:editable].should == true
    end
    
    

    it "should have the right file count when using a commit in the middle" do
      @repository.get_changed_files(@commit2.commit_hash).size.should == 1
    end
    
    it "should have the right name in the list when using a commit in the middle" do
      @repository.get_changed_files(@commit2.commit_hash).first[:name].should == 'file.xml'
    end
    
    it "should have the right path in the list when using a commit in the middle" do
      @repository.get_changed_files(@commit2.commit_hash).first[:path].should == 'path/to/file.xml'
    end
    
    it "should have the right type in the list when using a commit in the middle" do
      @repository.get_changed_files(@commit2.commit_hash).first[:type].should == :change
    end
    
    it "should have the right mime type in the list when using a commit in the middle" do
      @repository.get_changed_files(@commit2.commit_hash).first[:mime_type].should == Mime::Type.lookup_by_extension('xml')
    end
    
    it "should have the right mime category in the list when using a commit in the middle" do
      @repository.get_changed_files(@commit2.commit_hash).first[:mime_category].should == 'application'
    end
    
    it "should have the right editable in the list when using a commit in the middle" do
      @repository.get_changed_files(@commit2.commit_hash).first[:editable].should == true
    end
    
    

    it "should have the right file count when using the HEAD" do
      @repository.get_changed_files.size.should == 1
    end
    
    it "should have the right name in the list when using the HEAD" do
      @repository.get_changed_files.first[:name].should == 'file.xml'
    end
    
    it "should have the right path in the list when using the HEAD" do
      @repository.get_changed_files.first[:path].should == 'path/to/file.xml'
    end
    
    it "should have the right type in the list when using the HEAD" do
      @repository.get_changed_files.first[:type].should == :delete
    end
    
    it "should have the right mime type in the list when using the HEAD" do
      @repository.get_changed_files.first[:mime_type].should == Mime::Type.lookup_by_extension('xml')
    end
    
    it "should have the right mime category in the list when using the HEAD" do
      @repository.get_changed_files.first[:mime_category].should == 'application'
    end
    
    it "should have the right editable in the list when using the HEAD" do
      @repository.get_changed_files.first[:editable].should == true
    end
  end
end
