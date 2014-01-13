require 'spec_helper'

describe ApplicationController do
  it { should be_a(Supermarket::Authentication) }
  it { should be_a(Pundit) }
end
