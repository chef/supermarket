require 'spec_helper'

describe CookbookVersion do
  context 'associations' do
    it { should belong_to(:cookbook) }
  end

  context 'validations' do
    it { should validate_presence_of(:license) }
    it { should validate_presence_of(:version) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:cookbook_id) }
  end
end
