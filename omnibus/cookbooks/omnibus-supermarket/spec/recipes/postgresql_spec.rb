require 'spec_helper'

describe 'omnibus-supermarket::postgresql' do
  platform 'ubuntu', '16.04'
  automatic_attributes['memory']['total'] = '16000MB'
  normal_attributes['sysctl']['conf_dir'] = '/var/log/supermarket/postgresql'

  before :each do
    stub_command("grep 'SUP:123456:respawn:/opt/supermarket/embedded/bin/runsvdir-start' /etc/inittab")
  end

  it 'creates /var/log/supermarket/postgresql' do
    expect(chef_run).to create_directory('/var/log/supermarket/postgresql').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700'
    )
  end

  it 'sets shmmax sysctl param' do
    expect(chef_run).to apply_sysctl('kernel.shmmax').with(
      value: '17179869184'
    )
  end

  it 'sets shmall sysctl param' do
    expect(chef_run).to apply_sysctl('kernel.shmall').with(
      value: '4194304'
    )
  end
end
