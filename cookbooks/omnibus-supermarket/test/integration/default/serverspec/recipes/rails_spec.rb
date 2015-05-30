require 'spec_helper'

describe 'omnibus-supermarket::rails' do
  describe port(property['supermarket']['rails']['port']) do
    if property['supermarket']['rails']['enable']
      it { should be_listening.with('tcp') }
    else
      it { should_not be_listening.with('tcp') }
    end
  end

  describe file('/var/opt/supermarket/nginx/etc/sites-enabled/rails') do
     its(:content) { should match /ssl_dhparam/ }
  end
end
