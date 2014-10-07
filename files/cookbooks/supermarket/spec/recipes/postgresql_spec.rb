describe 'supermarket::postgresql' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

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

  it 'creates /var/opt/supermarket/postgresql/9.3/data' do
    expect(chef_run).to create_directory('/var/opt/supermarket/postgresql/9.3/data').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700',
    )
  end
end
