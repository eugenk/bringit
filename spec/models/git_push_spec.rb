require 'spec_helper'

describe GitPush do
  before do
    @push = GitPush.new(push_type: 'web')
  end
  
  subject { @push }
  
  it { should respond_to(:push_type) }
  
  it { should be_valid }
end
