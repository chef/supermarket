require 'spec_helper'

describe CookbookCollaborator do
  context 'associations' do
    it { should belong_to(:cookbook) }
    it { should belong_to(:user) }
  end
end
