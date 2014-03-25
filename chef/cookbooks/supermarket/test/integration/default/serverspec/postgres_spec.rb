require_relative 'spec_helper'

describe 'postgres' do
  it 'running' do
    expect(process 'postgres').to be_running
  end

  it 'listen tcp socket' do
    expect(port 5432).to be_listening
  end

  it 'has supermarket user' do
    cmd = command 'echo "\dg" | sudo -u postgres psql'
    expect(cmd.stdout).to match 'supermarket'
  end

  it 'has supermarket db' do
    cmd = command 'echo "\l" | sudo -u postgres psql'
    expect(cmd.stdout).to match 'supermarket_production'
  end
end
