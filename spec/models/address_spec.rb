require 'spec_helper'

describe Address do
  context 'associations' do
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:address_line_1) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:zip) }
    it { should validate_presence_of(:country) }
  end
end
