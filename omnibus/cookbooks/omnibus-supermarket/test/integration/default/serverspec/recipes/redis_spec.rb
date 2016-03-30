require 'spec_helper'

describe 'omnibus-supermarket::redis' do
  describe port(property['supermarket']['redis']['port']) do
    if property['supermarket']['redis']['enable']
      it { should be_listening.with('tcp') }
    else
      it { should_not be_listening.with('tcp') }
    end
  end
end
