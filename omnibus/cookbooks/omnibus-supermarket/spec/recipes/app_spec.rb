require 'spec_helper'

describe 'omnibus-supermarket::app' do
  platform 'ubuntu', '16.04'
  automatic_attributes['memory']['total'] = '16000MB'

  it 'creates /var/opt/supermarket/etc/env' do
    expect(chef_run).to create_file('/var/opt/supermarket/etc/env').with(
      owner: 'supermarket',
      group: 'supermarket',
      mode: '0600'
    )
  end

  it 'creates sitemap files with the correct permissions' do
    files = ['/opt/supermarket/embedded/service/supermarket/public/sitemap.xml.gz',
             '/opt/supermarket/embedded/service/supermarket/public/sitemap1.xml.gz']
    files.each do |file|
      expect(chef_run).to create_file(file)
        .with(owner: 'supermarket',
              group: 'supermarket',
              mode:  '0664')
    end
  end

  it 'links the env file' do
    expect(chef_run.link(
             '/opt/supermarket/embedded/service/supermarket/.env.production'
    )).to link_to('/var/opt/supermarket/etc/env')
  end

  it 'creates /var/opt/supermarket/etc/database.yml' do
    expect(chef_run).to create_file(
      '/var/opt/supermarket/etc/database.yml'
    ).with(
      owner: 'supermarket',
      group: 'supermarket',
      mode: '0600'
    )
  end

  it 'symlinks database.yml' do
    expect(chef_run.link('/opt/supermarket/embedded/service/supermarket/config/database.yml'))
      .to link_to('/var/opt/supermarket/etc/database.yml')
  end
end
