require_relative '../../libraries/config'

describe Supermarket::Config do
  describe 'environment_variables_from' do
    it 'creates environment varibles from attributes' do
      expect(described_class.environment_variables_from(
               'test1' => 123,
               'test2' => 'abc',
               'test3' => {},
               'test4' => [],
               'test5' => 'def',
               'test6' => true,
               'test7' => false,
               'test8' => nil
             )).to eq(
               <<~EXPORTS
                 export TEST1="123"
                 export TEST2="abc"
                 export TEST5="def"
                 export TEST6="true"
                 export TEST7="false"
               EXPORTS
             )
    end
  end

  describe '#load_or_create_secrets!' do
    let(:test_node) { Chef::Node.new }

    it 'populates the node object with keys/values from a JSON file' do
      secrets_file = Tempfile.new('test_secrets.json')
      secrets_file.write(JSON.generate(secret_key_base: 'value_from_json'))
      secrets_file.close

      described_class.load_or_create_secrets!(secrets_file.path, test_node)

      expect(test_node['supermarket']['secret_key_base']).to eq('value_from_json')
      secrets_file.unlink
    end

    context 'when the secrets JSON file does not exist' do
      let(:secrets_file) { Pathname.new(Dir.tmpdir).join('missing_secrets.json') }

      before do
        allow(Chef::Log).to receive(:warn)
      end

      after do
        File.delete(secrets_file)
      end

      context 'and a secret_key_base is set on the node object already' do
        it 'uses that secret_key_base, writes it to the file, and loads it' do
          test_node.consume_attributes('supermarket' => { 'secret_key_base' => 'value_set_already_elsewhere' })
          expect(SecureRandom).not_to receive(:hex)

          described_class.load_or_create_secrets!(secrets_file, test_node)

          expect(test_node['supermarket']['secret_key_base']).to eq('value_set_already_elsewhere')
          expect(File.exist?(secrets_file)).to be true
          expect(File.read(secrets_file)).to include('value_set_already_elsewhere')
          expect(Chef::Log).to have_received(:warn)
        end
      end

      context 'and no secret_key_base is already defined' do
        it 'generates a secret_key_base, writes it to the file, and loads it' do
          allow(SecureRandom).to receive(:hex).and_return('generated_value')

          described_class.load_or_create_secrets!(secrets_file, test_node)

          expect(test_node['supermarket']['secret_key_base']).to eq('generated_value')
          expect(File.exist?(secrets_file)).to be true
          expect(File.read(secrets_file)).to include('generated_value')
          expect(Chef::Log).to have_received(:warn)
        end
      end
    end
  end

  describe '#audit_config' do
    before(:each) do
      allow(described_class).to receive(:audit_s3_config)
      allow(described_class).to receive(:audit_fips_config)
    end

    it 'checks that the S3 configuration is valid' do
      expect(described_class).to receive(:audit_s3_config).with({ some: 'stuff' })
      described_class.audit_config({ some: 'stuff' })
    end

    it 'checks that the FIPS configuration is valid' do
      expect(described_class).to receive(:audit_fips_config).with({ some: 'stuff' })
      described_class.audit_config({ some: 'stuff' })
    end
  end

  describe '#audit_s3_config' do
    let(:all_required_settings) do
      {
        's3_bucket' => 'bettergetabucket',
        's3_region' => 'over-yonder-1',
      }
    end
    let(:default_settings) do
      { 's3_bucket' => nil, 's3_region' => nil }
    end

    context 'with settings required to enable S3 storage' do
      it 'passes if all required settings are present' do
        expect { described_class.audit_s3_config(all_required_settings) }
          .not_to raise_error
      end

      it 'passes if all required settings set to defaults' do
        expect { described_class.audit_s3_config(default_settings) }
          .not_to raise_error
      end

      it 'fails the chef run if required settings are incomplete' do
        incomplete_s3_config = default_settings.merge('s3_bucket' => 'bettergetabucket')
        expect { described_class.audit_s3_config(incomplete_s3_config) }
          .to raise_error(Supermarket::Config::IncompleteConfig)
      end

      it 'fails the chef run if required settings are set to empty values' do
        blank_s3_config = default_settings.merge('s3_bucket' => '', 's3_region' => '')
        expect { described_class.audit_s3_config(blank_s3_config) }
          .to raise_error(Supermarket::Config::IncompleteConfig)
      end
    end

    context 'with static IAM user credentials' do
      let(:all_required_static_credentials) do
        {
          's3_access_key_id' => 'thisismyidtherearemanylikeitbutthisoneismine',
          's3_secret_access_key' => 'superdupersecret',
        }
      end

      it 'passes if all required credentials are present' do
        with_static_credentials = all_required_settings.merge(all_required_static_credentials)
        expect { described_class.audit_s3_config(with_static_credentials) }
          .not_to raise_error
      end

      it 'fails the chef run if some but not all static credentials are present' do
        incomplete_static_credentials = all_required_settings.merge('s3_access_key_id' => 'thisismyidtherearemanylikeitbutthisoneismine')
        expect { described_class.audit_s3_config(incomplete_static_credentials) }
          .to raise_error(Supermarket::Config::IncompleteConfig)
      end

      it 'fails the chef run if the static credentials are set to empty values' do
        blank_static_credentials = all_required_settings.merge('s3_access_key_id' => '', 's3_secret_access_key' => '')
        expect { described_class.audit_s3_config(blank_static_credentials) }
          .to raise_error(Supermarket::Config::IncompleteConfig)
      end
    end

    context 'with compatible S3 bucket configurations' do
      [
        ['no-dot-in-bucket-name', 'us-east-1', ':s3_domain_url'],
        ['no-dot-in-bucket-name', 'us-east-1', ':s3_path_url'],
        ['no-dot-in-bucket-name', 'not-nova-1', ':s3_domain_url'],
        ['no-dot-in-bucket-name', 'not-nova-1', ':s3_path_url'],
        ['bucket.name.has.dots', 'us-east-1', ':s3_path_url'],
      ].each do |s3_bucket, s3_region, s3_domain_style|
        it "passes with #{s3_bucket}, #{s3_region}, and #{s3_domain_style}" do
          ok_config = all_required_settings.merge(
            's3_bucket' => s3_bucket,
            's3_region' => s3_region,
            's3_domain_style' => s3_domain_style
          )
          expect { described_class.audit_s3_config(ok_config) }
            .not_to raise_error
        end
      end
    end

    context 'with incompatible S3 bucket configurations' do
      [
        ['bucket.name.has.dots', 'us-east-1', ':s3_domain_url'],
        ['bucket.name.has.dots', 'not-nova-1', ':s3_domain_url'],
        ['bucket.name.has.dots', 'not-nova-1', ':s3_path_url'],
      ].each do |s3_bucket, s3_region, s3_domain_style|
        it "fails the chef run with #{s3_bucket}, #{s3_region}, and #{s3_domain_style}" do
          incompatible_config = all_required_settings.merge(
            's3_bucket' => s3_bucket,
            's3_region' => s3_region,
            's3_domain_style' => s3_domain_style
          )
          expect { described_class.audit_s3_config(incompatible_config) }
            .to raise_error(Supermarket::Config::IncompatibleConfig)
        end
      end
    end
  end

  describe '#audit_fips_config' do
    let(:default_config) do
      { 'fips_enabled' => nil }
    end

    context 'when the installer was built to support FIPS' do
      it 'does not raise' do
        expect(described_class).to receive(:built_with_fips?).and_return(true)

        expect { described_class.audit_fips_config(default_config) }
          .not_to raise_error
      end
    end

    context 'when the installer was not built to support FIPS' do
      before(:each) do
        expect(described_class).to receive(:built_with_fips?).and_return(false)
      end

      context 'and FIPS is not enabled in the kernel' do
        before(:each) do
          allow(described_class).to receive(:fips_enabled_in_kernel?).and_return(false)
        end

        it 'does not raise an error with the default config' do
          expect { described_class.audit_fips_config(default_config) }
            .not_to raise_error
        end

        it 'raises an error if user has explicitly enabled FIPS in config' do
          explicitly_enable_fips = { 'fips_enabled' => true }

          expect { described_class.audit_fips_config(explicitly_enable_fips) }
            .to raise_error(Supermarket::Config::IncompatibleConfig)
        end
      end

      it 'raises an error if FIPS is enabled in the kernel' do
        expect(described_class).to receive(:fips_enabled_in_kernel?).and_return(true)

        expect { described_class.audit_fips_config(default_config) }
          .to raise_error(Supermarket::Config::IncompatibleConfig)
      end
    end
  end

  describe '#maybe_turn_on_fips' do
    let(:node) { Chef::Node.new() }

    context 'with the default setting' do
      before(:each) do
        node.default['supermarket']['fips_enabled'] = nil
      end

      context 'and a kernel without FIPS enabled (the usual path)' do
        before(:each) do
          allow(described_class).to receive(:fips_enabled_in_kernel?).and_return(false)
        end

        it 'does not enable FIPS' do
          described_class.maybe_turn_on_fips(node)
          expect(node['supermarket']['fips_enabled']).to be false
        end
      end

      context 'and a kernel with FIPS enabled' do
        before(:each) do
          allow(described_class).to receive(:fips_enabled_in_kernel?).and_return(true)
        end

        it 'enables FIPS and logs messages about it' do
          expect(Chef::Log).to receive(:warn).with('Detected FIPS-enabled kernel; enabling FIPS 140-2 for Supermarket services.')
          described_class.maybe_turn_on_fips(node)
          expect(node['supermarket']['fips_enabled']).to be true
        end
      end
    end

    context 'with fips_enabled set to true' do
      before(:each) do
        node.consume_attributes('supermarket' => { 'fips_enabled' => true })
      end

      it 'enables FIPS and logs messages about it' do
        expect(Chef::Log).to receive(:warn).with('Overriding FIPS detection: FIPS 140-2 mode is ON.')
        described_class.maybe_turn_on_fips(node)
        expect(node['supermarket']['fips_enabled']).to be true
      end
    end

    context 'with fips_enabled set to false' do
      before(:each) do
        node.consume_attributes('supermarket' => { 'fips_enabled' => false })
      end

      context 'and a kernel without FIPS enabled' do
        before(:each) do
          allow(described_class).to receive(:fips_enabled_in_kernel?).and_return(false)
        end

        it 'does not enable FIPS' do
          described_class.maybe_turn_on_fips(node)
          expect(node['supermarket']['fips_enabled']).to be false
        end
      end

      context 'and a kernel with FIPS enabled' do
        before(:each) do
          allow(described_class).to receive(:fips_enabled_in_kernel?).and_return(true)
        end

        it 'enables FIPS anyway and logs messages about why you gotta FIPS when it is enabled in the kernel' do
          expect(Chef::Log).to receive(:warn).with('Detected FIPS-enabled kernel; enabling FIPS 140-2 for Supermarket services.')
          expect(Chef::Log).to receive(:warn).with('fips_enabled was set to false; ignoring this and setting to true or else Supermarket services will fail with crypto errors.')
          described_class.maybe_turn_on_fips(node)
          expect(node['supermarket']['fips_enabled']).to be true
        end
      end
    end

    context 'with fips_enabled set to anything other than nil or boolean true/false' do
      ['true', 'false', 'FALSE!', 'PLEASE! TURN THIS OFF!', 42].each do |anything|
        it "assumes the #{anything.class} '#{anything}' means 'turn it on' and enables FIPS" do
          node.consume_attributes('supermarket' => { 'fips_enabled' => anything })

          expect(Chef::Log).to receive(:warn).with('Overriding FIPS detection: FIPS 140-2 mode is ON.')
          expect(Chef::Log).to receive(:warn).with('fips_enabled is set to something other than boolean true/false; assuming FIPS mode should be enabled.')
          described_class.maybe_turn_on_fips(node)
          expect(node['supermarket']['fips_enabled']).to be true
        end
      end
    end
  end
end
