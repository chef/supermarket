describe 'supermarket::config' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'creates /etc/supermarket' do
    expect(chef_run).to create_directory('/etc/supermarket').with(
      user: 'root',
      group: 'root',
    )
  end

  it 'creates /etc/supermarket/supermarket.rb if it does not exist' do
    expect(chef_run).to create_template_if_missing('/etc/supermarket/supermarket.rb').with(
      user: 'root',
      group: 'root',
      mode: '0644',
    )
  end
end
