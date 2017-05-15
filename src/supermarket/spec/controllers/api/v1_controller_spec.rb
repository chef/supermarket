require 'spec_helper'
class Api::V1Controller::SomeV1Controller < Api::V1Controller; end

describe Api::V1Controller::SomeV1Controller do
  it_behaves_like 'an API v1 controller'
end
