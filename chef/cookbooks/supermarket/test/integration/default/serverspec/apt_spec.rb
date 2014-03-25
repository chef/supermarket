require_relative 'spec_helper'

describe 'apt' do
  it 'in correct state' do
    expect(command 'apt-get check').to return_exit_status 0
    expect(command 'dpkg -C').to return_exit_status 0
  end
end
