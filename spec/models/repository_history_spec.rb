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
  
  describe "when getting the history of a file" do
    before do
      @repository.save
      @filepath = 'path/to/file.txt'
      @commit_add1 = @repository.commit_file(@repository.owners.first, 'Some content1', @filepath, 'Add')
      @commit_change1 = @repository.commit_file(@repository.owners.first, 'Some other content1', @filepath, 'Change')
      @commit_other1 = @repository.commit_file(@repository.owners.first, 'Other content1', 'file2.txt', 'Other File: Add')
      @commit_delete1 = @repository.delete_file(@repository.owners.first, @filepath)
      @commit_other2 = @repository.commit_file(@repository.owners.first, 'Other content2', 'file2.txt', 'Other File: Change1')
      @commit_other3 = @repository.commit_file(@repository.owners.first, 'Other content3', 'file2.txt', 'Other File: Change2')
      @commit_add2 = @repository.commit_file(@repository.owners.first, 'Some content2', @filepath, 'Re-Add')
      @commit_change2 = @repository.commit_file(@repository.owners.first, 'Some other content2', @filepath, 'Re-Change')
      @commit_delete2 = @repository.delete_file(@repository.owners.first, @filepath)
    end

    it "should have the correct values in the history at the HEAD" do
      @repository.entry_info_list(@filepath).should == [
        @commit_delete2,
        @commit_change2,
        @commit_add2,
        @commit_delete1,
        @commit_change1,
        @commit_add1
      ].map { |c| c.commit_hash }
    end

    it "should have the correct values in the history a commit before the HEAD" do
      @repository.entry_info_list(@filepath, @commit_change2.commit_hash).should == [
        @commit_change2,
        @commit_add2,
        @commit_delete1,
        @commit_change1,
        @commit_add1
      ].map { |c| c.commit_hash }
    end

    it "should have the correct values in the history in the commit that changes another file" do
      @repository.entry_info_list(@filepath, @commit_other3.commit_hash).should == [
        @commit_delete1,
        @commit_change1,
        @commit_add1
      ].map { |c| c.commit_hash }
    end
  end
end
