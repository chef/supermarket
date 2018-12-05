require 'spec_helper'

describe 'omnibus-supermarket::nginx' do
  platform 'ubuntu', '16.04'
  automatic_attributes['memory']['total'] = '16000MB'

  it 'creates /var/log/supermarket/nginx' do
    expect(chef_run).to create_directory('/var/log/supermarket/nginx').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700'
    )
  end

  it 'creates /var/opt/supermarket/nginx/etc' do
    expect(chef_run).to create_directory('/var/opt/supermarket/nginx/etc').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700'
    )
  end

  it 'creates /var/opt/supermarket/nginx/etc/conf.d' do
    expect(chef_run).to create_directory('/var/opt/supermarket/nginx/etc/conf.d').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700'
    )
  end

  it 'creates /var/opt/supermarket/nginx/etc/sites_enabled' do
    expect(chef_run).to create_directory('/var/opt/supermarket/nginx/etc/sites-enabled').with(
      user: 'supermarket',
      group: 'supermarket',
      mode: '0700'
    )
  end

  it 'creates /var/opt/supermarket/nginx/etc/nginx.conf' do
    expect(chef_run).to create_template('/var/opt/supermarket/nginx/etc/nginx.conf').with(
      source: 'nginx.conf.erb',
      owner: 'supermarket',
      group: 'supermarket',
      mode: '0600'
    )
  end

  it 'symlinks the mime types' do
    expect(chef_run.link('/var/opt/supermarket/nginx/etc/mime.types')).to link_to(
      '/opt/supermarket/embedded/conf/mime.types'
    )
  end

  it 'notifies nginx to reload when it renders the config' do
    expect(chef_run.template('/var/opt/supermarket/nginx/etc/nginx.conf'))
      .to notify('component_runit_service[nginx]').to(:restart)
  end

  it 'creates /var/opt/supermarket/etc/logrotate.d/nginx' do
    expect(chef_run).to create_template('/var/opt/supermarket/etc/logrotate.d/nginx').with(
      source: 'logrotate-rule.erb',
      owner: 'root',
      group: 'root',
      mode: '0644',
      variables: {
        'log_directory' => '/var/log/supermarket/nginx',
        'log_rotation' => {
          'file_maxbytes' => 104857600,
          'num_to_keep' => 10,
        },
        'postrotate' => '/opt/supermarket/embedded/sbin/nginx -c /var/opt/supermarket/nginx/etc/nginx.conf -s reopen',
        'owner' => 'root',
        'group' => 'root',
      }
    )
  end
end
