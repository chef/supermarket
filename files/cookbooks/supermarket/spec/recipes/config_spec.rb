describe 'supermarket::config' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'creates /etc/supermarket' do
    expect(chef_run).to create_directory('/etc/supermarket').with(
      user: 'root',
      group: 'root',
    )
  end
end
