require 'spec_helper'

describe GitPush do
  before do
    @push = GitPush.new(push_type: 'web')
  end
  
  subject { @push }
  
  it { should respond_to(:push_type) }
  
  it { should be_valid }
  
  describe "when second push_type is valid" do
    before { @push.push_type = 'ssh' }
    it { should be_valid }
  end
  
  describe "when push_type is not valid" do
    before { @push.push_type = @push.push_type.upcase }
    it { should_not be_valid }
  end
end
