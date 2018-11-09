require 'spec_helper'

describe 'omnibus-supermarket::database' do
  platform 'ubuntu', '16.04'
  automatic_attributes['memory']['total'] = '16000MB'

  before do
    stub_command("echo '\\dx' | psql supermarket | grep plpgsql").and_return('')
    stub_command("echo '\\dx' | psql supermarket | grep pg_trgm").and_return('')
  end
end
