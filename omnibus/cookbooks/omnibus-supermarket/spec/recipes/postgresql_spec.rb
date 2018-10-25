describe 'omnibus-supermarket::postgresql' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '16.04') do |node|
      node.automatic['memory']['total'] = '16000MB'
      node.normal['sysctl']['conf_dir'] = '/var/log/supermarket/postgresql'
    end.converge(described_recipe)
  end

  before :each do
    stub_command("grep 'SUP:123456:respawn:/opt/supermarket/embedded/bin/runsvdir-start' /etc/inittab")
  end

  it 'creates /var/log/supermarket/postgresql' do
    expect(chef_run).to create_directory('/var/log/supermarket/postgresql').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700',
    )
  end

  it 'sets shmmax sysctl param' do
    expect(chef_run).to apply_sysctl('kernel.shmmax').with(
      value: 17179869184
    )
  end

  it 'sets shmall sysctl param' do
    expect(chef_run).to apply_sysctl('kernel.shmall').with(
      value: 4194304
    )
  end
end
