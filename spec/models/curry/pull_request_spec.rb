require 'spec_helper'

describe Curry::PullRequest do

  describe 'validations' do
    it { should validate_presence_of(:number) }
    it { should validate_presence_of(:repository_id) }
  end

end
