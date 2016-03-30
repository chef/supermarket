require 'spec_helper'

describe CookbookVersionPlatform do
  it { should validate_presence_of(:cookbook_version) }
  it { should validate_presence_of(:supported_platform) }
end
