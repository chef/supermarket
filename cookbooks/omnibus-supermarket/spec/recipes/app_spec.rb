describe 'omnibus-supermarket::app' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.automatic['memory']['total'] = '16000MB'
    end.converge(described_recipe)
  end

  it 'creates /var/opt/supermarket/etc/env' do
    expect(chef_run).to create_file('/var/opt/supermarket/etc/env').with(
      owner: 'supermarket',
      group: 'supermarket',
      mode: '0600',
    )
  end

  it 'links the env file' do
    expect(chef_run.link(
      '/opt/supermarket/embedded/service/supermarket/.env.production'
    )).to link_to('/var/opt/supermarket/etc/env')
  end
end
