require 'spec_helper'

describe Tool do
  context 'associations' do
    it { should belong_to(:user) }
  end
end
