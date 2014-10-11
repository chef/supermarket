describe 'supermarket::config' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
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

  it 'creates /etc/supermarket/supermarket.rb if it does not exist' do
    expect(chef_run).to create_template_if_missing('/etc/supermarket/supermarket.rb').with(
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
end
