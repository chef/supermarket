require 'spec_helper'

describe Hit do
  context 'validations' do
    it { should validate_presence_of(:label) }
    it { should validate_presence_of(:total) }
    it { should validate_numericality_of(:total) }
  end
end
