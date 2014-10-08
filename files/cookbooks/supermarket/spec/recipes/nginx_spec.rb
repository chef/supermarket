describe 'supermarket::nginx' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.automatic['memory']['total'] = '16000MB'
    end.converge(described_recipe)
  end

  it 'creates /var/log/supermarket/nginx' do
    expect(chef_run).to create_directory('/var/log/supermarket/nginx').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700',
    )
  end

  it 'creates /var/opt/supermarket/nginx/etc' do
    expect(chef_run).to create_directory('/var/opt/supermarket/nginx/etc').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700',
    )
  end

  it 'creates /var/opt/supermarket/nginx/etc/nginx.d' do
    expect(chef_run).to create_directory('/var/opt/supermarket/nginx/etc/nginx.d').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700',
    )
  end

  it 'creates /var/opt/supermarket/nginx/etc/nginx.conf' do
    expect(chef_run).to create_template('/var/opt/supermarket/nginx/etc/nginx.conf').with(
      source: 'nginx.conf.erb',
      owner: 'supermarket',
      group: 'supermarket',
      mode: '0600',
    )
  end

  it 'notifies nginx to reload when it renders the config' do
    expect(chef_run.template('/var/opt/supermarket/nginx/etc/nginx.conf'))
      .to notify('runit_service[nginx]').to(:hup)
  end
end
