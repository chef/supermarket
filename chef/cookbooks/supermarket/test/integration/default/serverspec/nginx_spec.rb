require_relative 'spec_helper'

describe 'nginx' do
  it 'running' do
    expect(process 'nginx').to be_running
  end

  it 'listen on port 80' do
    expect(port 80).to be_listening
  end

  it 'default site is supermarket' do
    config = '/etc/nginx/sites-available/default'
    expect(file '/etc/nginx/sites-enabled/default').to be_linked_to config
    expect(file(config).content).to match 'upstream unicorn'
  end
end
