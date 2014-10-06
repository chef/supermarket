describe 'supermarket::redis' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  before :each do
    stub_command("grep 'SV:123456:respawn:/opt/supermarket/embedded/bin/runsvdir-start' /etc/inittab")
  end

  it 'creates /var/log/supermarket/redis' do
    expect(chef_run).to create_directory('/var/log/supermarket/redis').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700',
    )
  end

  it 'creates /var/opt/supermarket/redis/etc' do
    expect(chef_run).to create_directory('/var/opt/supermarket/redis/etc').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700',
    )
  end

  it 'creates /var/opt/supermarket/redis/etc/redis.conf' do
    expect(chef_run).to create_template(
      '/var/opt/supermarket/redis/etc/redis.conf'
    ).with(
      owner: 'supermarket',
      group: 'supermarket',
      mode: '0600',
    )
  end

  it 'creates /var/opt/supermarket/lib/redis' do
    expect(chef_run).to create_directory('/var/opt/supermarket/lib/redis').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700',
    )
  end

  it 'creates /var/opt/supermarket/redis/run' do
    expect(chef_run).to create_directory('/var/opt/supermarket/redis/run').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700',
    )
  end
end
