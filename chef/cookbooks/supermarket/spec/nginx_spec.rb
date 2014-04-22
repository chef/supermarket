require_relative 'spec_helper'

describe 'supermarket::_nginx' do
  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  it 'reloads the service when the default sites-available conf changes' do
    resource = chef_run.template('/etc/nginx/sites-available/default')

    expect(resource).to notify('service[nginx]').to(:reload)
  end
end
