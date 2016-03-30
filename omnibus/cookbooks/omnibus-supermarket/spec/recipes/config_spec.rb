describe 'omnibus-supermarket::config' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.automatic['memory']['total'] = '16000MB'
    end.converge(described_recipe)
  end

  it 'creates the supermarket user' do
    expect(chef_run).to create_user('supermarket')
  end

  it 'creates the supermarket group' do
    expect(chef_run).to create_group('supermarket')
      .with(members: ['supermarket'])
  end

  it 'creates /etc/supermarket' do
    expect(chef_run).to create_directory('/etc/supermarket').with(
      user: 'supermarket',
      group: 'supermarket',
    )
  end

  it 'creates /etc/supermarket/supermarket.rb' do
    expect(chef_run).to create_file('/etc/supermarket/supermarket.rb').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0600',
    )
  end

  it 'creates /var/opt/supermarket' do
    expect(chef_run).to create_directory('/var/opt/supermarket').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700',
    )
  end

  it 'creates /var/opt/supermarket/etc' do
    expect(chef_run).to create_directory('/var/opt/supermarket/etc').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700',
    )
  end
end
