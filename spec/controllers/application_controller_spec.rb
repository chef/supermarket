require 'spec_helper'

describe ApplicationController do
  it { should be_a(Supermarket::Authorization) }
  it { should be_a(Supermarket::LocationStorage) }
end
