require 'spec_helper'

describe 'omnibus-supermarket::postgresql' do
  describe port(property['supermarket']['postgresql']['port']) do
    if property['supermarket']['postgresql']['enable']
      it { should be_listening.with('tcp') }
    else
      it { should_not be_listening.with('tcp') }
    end
  end
end
