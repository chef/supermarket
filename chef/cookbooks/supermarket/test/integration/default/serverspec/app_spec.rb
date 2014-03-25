require_relative 'spec_helper'

describe 'supermarket' do
  it 'create a unicorn socket' do
    expect(file '/tmp/.supermarket.sock.0').to be_socket
  end

  it 'serve Chef Supermarket index web page' do
    cmd = command 'wget -O - http://localhost 2> /dev/null'
    expect(cmd.stdout).to match '<title>Chef Supermarket</title>'
  end
end
