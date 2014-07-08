require 'spec_helper'

describe Hit do
  context 'validations' do
    it { should validate_presence_of(:universe) }
    it { should validate_numericality_of(:universe) }
  end
end
