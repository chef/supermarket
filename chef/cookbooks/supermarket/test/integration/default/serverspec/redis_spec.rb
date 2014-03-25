require_relative 'spec_helper'

describe 'redis' do
  it 'running' do
    expect(process 'redis-server').to be_running
  end

  it 'listen tcp socket' do
    expect(port 6379).to be_listening
  end
end
