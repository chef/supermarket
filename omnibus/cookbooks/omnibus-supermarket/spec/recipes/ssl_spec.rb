require 'spec_helper'

describe 'omnibus-supermarket::ssl' do
  platform 'ubuntu', '18.04'
  automatic_attributes['memory']['total'] = '16000MB'

  # Shared Example Sets
  # - :create_directories - Creates the directories for SSL
  # - :create_certificates - When the recipe should create certs
  # - :create_dhparams - When the recipe should create a dhparams.pem
  # - :no_create_certificates - When the recipe should not create certs
  # - :no_create_dhparams - When the recipe should not create dhparams.pem

  shared_examples_for :create_directories do
    it 'creates /var/opt/supermarket/ssl' do
      expect(chef_run).to create_directory('/var/opt/supermarket/ssl').with(
        user: 'supermarket',
        group: 'supermarket',
        mode: '0700'
      )
    end

    it 'creates /var/opt/supermarket/ssl/ca' do
      expect(chef_run).to create_directory('/var/opt/supermarket/ssl/ca').with(
        user: 'supermarket',
        group: 'supermarket',
        mode: '0700'
      )
    end
  end

  shared_examples_for :create_certificates do
    it 'creates /var/opt/supermarket/ssl/ca/fauxhai.local.crt' do
      expect(chef_run).to create_openssl_x509_certificate(
        '/var/opt/supermarket/ssl/ca/fauxhai.local.crt'
      ).with(
        common_name: 'fauxhai.local',
        org: 'My Supermarket',
        org_unit: 'Operations',
        country: 'US',
        key_length: 4096,
        expire: 3650,
        owner: 'root',
        group: 'root',
        mode: '0644'
      )
    end
  end

  shared_examples_for :create_dhparams do
    it 'creates /var/opt/supermarket/ssl/ca/dhparams.pem' do
      expect(chef_run).to create_openssl_dhparam(
        '/var/opt/supermarket/ssl/ca/dhparams.pem'
      ).with(
        key_length: 4096,
        generator: 2,
        owner: 'root',
        group: 'root',
        mode: '0644'
      )
    end
  end

  shared_examples_for :no_create_certificates do
    it 'does not create an x509 certificate' do
      expect(chef_run).not_to create_openssl_x509_certificate(
        '/var/opt/supermarket/ssl/ca/fauxhai.local.crt')
    end
  end

  shared_examples_for :no_create_dhparams do
    it 'does not create a dhparams.pem file' do
      expect(chef_run).not_to create_openssl_dhparam(
        '/var/opt/supermarket/ssl/ca/dhparams.pem'
      )
    end
  end

  # Chef Run contexts, varied based on feature flag attributes
  # - Default run: Creates SSL certificates
  #   with certificate supplied: Uses supplied cert location
  # - SSL disabled: Creates directories, does not create or link certificates
  # - With certificate location & SSL disabled: Tests that ssl disable
  #   supercedes supplied certificate behavior.
  context 'When all attributes are default, on a fauxhai\'d platform:' do
    it_behaves_like :create_directories
    it_behaves_like :create_certificates
    it_behaves_like :create_dhparams

    it 'sets the [\'supermarket\'][\'ssl\'] attributes correctly' do
      expect(chef_run.node['supermarket']['ssl']['certificate'])
        .to eq('/var/opt/supermarket/ssl/ca/fauxhai.local.crt')
      expect(chef_run.node['supermarket']['ssl']['certificate_key'])
        .to eq('/var/opt/supermarket/ssl/ca/fauxhai.local.key')
      expect(chef_run.node['supermarket']['ssl']['ssl_dhparam'])
        .to eq('/var/opt/supermarket/ssl/ca/dhparams.pem')
    end

    it 'links the CA cert to /var/opt/supermarket/ssl/ca/fauxhai.local.crt' do
      expect(chef_run).to create_link(
        '/var/opt/supermarket/ssl/cacert.pem'
      ).with(
        to: '/var/opt/supermarket/ssl/ca/fauxhai.local.crt'
      )
    end
  end

  context 'When a certificate is supplied, on a fauxhai\'d platform:' do
    normal_attributes['supermarket']['ssl']['certificate'] = '/etc/mycert.pem'

    it_behaves_like :create_directories
    it_behaves_like :no_create_certificates
    it_behaves_like :create_dhparams

    it 'sets the [\'supermarket\'][\'ssl\'] attributes correctly' do
      expect(chef_run.node['supermarket']['ssl']['certificate'])
        .to eq('/etc/mycert.pem')
      expect(chef_run.node['supermarket']['ssl']['certificate_key'])
        .to be_nil
      expect(chef_run.node['supermarket']['ssl']['ssl_dhparam'])
        .to eq('/var/opt/supermarket/ssl/ca/dhparams.pem')
    end

    it 'links the CA cert to /opt/supermarket/embedded/ssl/certs/cacert.pem' do
      expect(chef_run).to create_link(
        '/var/opt/supermarket/ssl/cacert.pem'
      ).with(
        to: '/opt/supermarket/embedded/ssl/certs/cacert.pem'
      )
    end
  end

  context 'when ssl is disabled, on a fauxhai\'d platform' do
    normal_attributes['supermarket']['ssl']['enable'] = false

    it_behaves_like :create_directories
    it_behaves_like :no_create_certificates
    it_behaves_like :no_create_dhparams

    it 'does not set the [\'supermarket\'][\'ssl\'] attributes' do
      expect(chef_run.node['supermarket']['ssl']['certificate'])
        .to be_nil
      expect(chef_run.node['supermarket']['ssl']['certificate_key'])
        .to be_nil
      expect(chef_run.node['supermarket']['ssl']['ssl_dhparam'])
        .to be_nil
    end

    it 'does not create the CA cert symlink' do
      expect(chef_run).not_to create_link(
        '/var/opt/supermarket/ssl/cacert.pem')
    end
  end

  context 'when ssl is disabled & a certificate is supplied, ' \
          'on a fauxhai\'d platform' do
    normal_attributes['supermarket']['ssl']['enable'] = false
    normal_attributes['supermarket']['ssl']['certificate'] = '/etc/mycert.pem'

    it_behaves_like :create_directories
    it_behaves_like :no_create_certificates
    it_behaves_like :no_create_dhparams

    it 'does not modify the [\'supermarket\'][\'ssl\'] attributes' do
      expect(chef_run.node['supermarket']['ssl']['certificate'])
        .to eq('/etc/mycert.pem')
      expect(chef_run.node['supermarket']['ssl']['certificate_key'])
        .to be_nil
      expect(chef_run.node['supermarket']['ssl']['ssl_dhparam'])
        .to be_nil
    end

    it 'does not create the CA cert symlink' do
      expect(chef_run).not_to create_link(
        '/var/opt/supermarket/ssl/cacert.pem')
    end
  end
end
