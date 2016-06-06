require 'spec_helper'

describe 'supermarket-ctl make-admin' do
  # run as someone other that the supermarket OS user
  describe command("supermarket-ctl make-admin") do
    its(:stderr) { should match /supermarket-ctl make-admin should be run as the supermarket OS user./ }
  end

  # run as supermarket user, but with a user that doesn't exist
  describe command("sudo -u supermarket supermarket-ctl make-admin user=nope") do
    its(:stdout) { should match /nope was not found in Supermarket./ }
  end
end
