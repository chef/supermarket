require 'spec_helper'

describe 'supermarket-ctl test' do
  # run as someone other that the supermarket OS user
  describe command("supermarket-ctl test") do
    its(:stderr) { should match /supermarket-ctl test should be run as the supermarket OS user./ }
  end
end
