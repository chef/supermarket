require 'spec_helper'

describe Icla do
  it { should validate_uniqueness_of(:version) }
end
