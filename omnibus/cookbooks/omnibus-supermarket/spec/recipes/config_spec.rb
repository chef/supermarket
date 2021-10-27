require 'spec_helper'

describe 'omnibus-supermarket::config' do
  platform 'ubuntu', '18.04'
  automatic_attributes['memory']['total'] = '16000MB'

  it 'creates the supermarket user' do
    expect(chef_run).to create_user('supermarket').with(shell: '/bin/false', system: true)
  end

  it 'creates the supermarket group' do
    expect(chef_run).to create_group('supermarket')
      .with(members: ['supermarket'])
  end

  it 'creates /etc/supermarket' do
    expect(chef_run).to create_directory('/etc/supermarket').with(
      user: 'supermarket',
      group: 'supermarket'
    )
  end

  it 'creates /etc/supermarket/supermarket.rb' do
    expect(chef_run).to create_file('/etc/supermarket/supermarket.rb').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0600'
    )
  end

  it 'creates /var/opt/supermarket' do
    expect(chef_run).to create_directory('/var/opt/supermarket').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700'
    )
  end

  it 'creates /var/opt/supermarket/etc' do
    expect(chef_run).to create_directory('/var/opt/supermarket/etc').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700'
    )
  end
end
