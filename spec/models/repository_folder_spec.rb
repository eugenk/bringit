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

  describe "can read a folder" do
    before do
      @repository.save
      @commit_add1 = @repository.commit_file(@user, 'Some content', 'path/file1.txt', 'Some commit message1')
      @commit_add2 = @repository.commit_file(@user, 'Some content', 'path/file2.txt', 'Some commit message2')
      @commit_add3 = @repository.commit_file(@user, 'Some content', 'file3.txt', 'Some commit message2')
      @commit_del1 = @repository.delete_file(@user, 'path/file1.txt')
      @commit_del2 = @repository.delete_file(@user, 'path/file2.txt')
      @commit_del3 = @repository.delete_file(@user, 'file3.txt')
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
end
