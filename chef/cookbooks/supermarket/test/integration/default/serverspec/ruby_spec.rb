require_relative 'spec_helper'

describe 'ruby' do
  it '2.0.0 installed and used by default' do
    cmd = command 'ruby -v'
    expect(cmd.stdout).to match 'ruby 2.0.0'
  end
end
