describe 'omnibus-supermarket::app' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
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

  it 'creates sitemap files with the correct permissions' do
    files = ['/opt/supermarket/embedded/service/supermarket/public/sitemap.xml.gz',
             '/opt/supermarket/embedded/service/supermarket/public/sitemap1.xml.gz']
    files.each do |file|
      expect(chef_run).to create_file(file)
        .with( owner: 'supermarket',
               group: 'supermarket',
               mode:  '0664' )
    end
  end

  it 'links the env file' do
    expect(chef_run.link(
      '/opt/supermarket/embedded/service/supermarket/.env.production'
    )).to link_to('/var/opt/supermarket/etc/env')
  end
end
