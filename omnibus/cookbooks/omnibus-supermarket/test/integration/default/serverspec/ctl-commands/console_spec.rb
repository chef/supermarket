require 'spec_helper'

describe 'supermarket-ctl console' do
  # run as someone other that the supermarket OS user
  describe command("supermarket-ctl console") do
    its(:stderr) { should match /supermarket-ctl console should be run as the supermarket OS user./ }
  end
end
