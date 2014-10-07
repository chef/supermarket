describe 'supermarket::postgresql' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.automatic['memory']['total'] = '16000MB'
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
end
