require 'spec_helper'

describe 'omnibus-supermarket::ssl' do
  describe file('/var/opt/supermarket/ssl/ca/dhparams.pem') do
    it { should be_file }

    its(:content) { should match /BEGIN DH PARAMETERS/}
  end
end
