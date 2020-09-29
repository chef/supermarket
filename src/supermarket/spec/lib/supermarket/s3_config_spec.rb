require "spec_helper"

describe Supermarket::S3Config do
  context "#use_s3?" do
    it "is true if required S3 configs are given in environment" do
      mock_env = {
        "S3_BUCKET" => "bettergetabucket",
        "S3_REGION" => "over-yonder-1",
      }
      expect(Supermarket::S3Config.use_s3?(mock_env)).to be true
    end

    it "is false if no required S3 configs are given in the environment" do
      mock_env = {}
      expect(Supermarket::S3Config.use_s3?(mock_env)).to be false
    end

    it "throws an exception if some but not all of the required S3 configs are present" do
      mock_env = {
        "S3_BUCKET" => "bettergetabucket",
      }
      expect { Supermarket::S3Config.use_s3?(mock_env) }.to raise_exception Supermarket::S3Config::IncompleteConfig
    end

    it "throws an exception if any of the required S3 configs are blank" do
      mock_env = {
        "S3_BUCKET" => "",
        "S3_REGION" => "",
      }
      expect { Supermarket::S3Config.use_s3?(mock_env) }.to raise_exception Supermarket::S3Config::IncompleteConfig
    end
  end

  context "#use_s3_with_static_creds?" do
    it "is true if both S3_ACCESS_KEY_ID and S3_SECRET_ACCESS_KEY are present" do
      mock_env = {
        "S3_ACCESS_KEY_ID" => "thisismyidtherearemanylikeitbutthisoneismine",
        "S3_SECRET_ACCESS_KEY" => "superdupersecret",
      }
      config = Supermarket::S3Config.new("some_path", mock_env)
      expect(config.send(:use_s3_with_static_creds?)).to be true
    end

    it "is false if S3_ACCESS_KEY_ID and S3_SECRET_ACCESS_KEY are absent" do
      mock_env = {}
      config = Supermarket::S3Config.new("some_path", mock_env)
      expect(config.send(:use_s3_with_static_creds?)).to be false
    end

    it "throws an exception if only S3_ACCESS_KEY_ID or only S3_SECRET_ACCESS_KEY is present" do
      mock_env = {
        "S3_ACCESS_KEY_ID" => "thisismyidtherearemanylikeitbutthisoneismine",
      }
      config = Supermarket::S3Config.new("some_path", mock_env)
      expect { config.send(:use_s3_with_static_creds?) }.to raise_exception Supermarket::S3Config::IncompleteConfig
    end

    it "throws an exception if S3_ACCESS_KEY_ID or S3_SECRET_ACCESS_KEY is an empty string" do
      mock_env = {
        "S3_ACCESS_KEY_ID" => "",
        "S3_SECRET_ACCESS_KEY" => "",
      }
      config = Supermarket::S3Config.new("some_path", mock_env)
      expect { config.send(:use_s3_with_static_creds?) }.to raise_exception Supermarket::S3Config::IncompleteConfig
    end
  end

  context "#to_paperclip_options" do
    let(:minimum_s3_env) {
      {
        "S3_BUCKET" => "bettergetabucket",
        "S3_REGION" => "over-yonder-1",
        "S3_DOMAIN_STYLE" => ":s3_domain_url",
      }
    }

    context "defaults" do
      let(:default_options) { Supermarket::S3Config.new(":class/:attachment/:yadda/:yadda", minimum_s3_env).to_paperclip_options }

      it "storage is :s3" do
        expect(default_options[:storage]).to eq "s3"
      end

      it "path is the path given in params" do
        expect(default_options[:path]).to eq ":class/:attachment/:yadda/:yadda"
      end

      it "bucket is set from the environment" do
        expect(default_options[:bucket]).to eq "bettergetabucket"
      end

      it "s3_credentials is set to the basics from the environment" do
        expect(default_options[:s3_credentials]).to eq({
          bucket: "bettergetabucket",
          s3_region: "over-yonder-1",
        })
      end

      it "url style is set from the environment" do
        expect(default_options[:url]).to eq ":s3_domain_url"
      end
    end

    it "changes the S3 endpoint if an alternate is set" do
      alt_endpoint = "http://something.local:4566"
      alt_hostname_and_port = "something.local:4566"
      mock_env = minimum_s3_env.merge({ "S3_ENDPOINT" => alt_endpoint })
      expect(Aws.config).to receive(:update).with(endpoint: alt_endpoint, force_path_style: true)
      options = Supermarket::S3Config.new("some_path", mock_env).to_paperclip_options
      expect(options[:s3_options]).to eq({ endpoint: alt_endpoint })
      expect(options[:s3_host_name]).to eq(alt_hostname_and_port)
    end

    it "if S3_PATH is set, it gets prefixed onto the artifact path pattern" do
      mock_env = minimum_s3_env.merge({ "S3_PATH" => "an_s3_path" })
      options = Supermarket::S3Config.new(":class/:attachment/:yadda/:yadda", mock_env).to_paperclip_options
      expect(options[:path]).to start_with "an_s3_path"
    end

    it "if S3_PRIVATE_OBJECTS is set to 'true', it sets private s3_permissions" do
      mock_env = minimum_s3_env.merge({ "S3_PRIVATE_OBJECTS" => "true" })
      options = Supermarket::S3Config.new("some_path", mock_env).to_paperclip_options
      expect(options[:s3_permissions]).to be :private
    end

    it "if S3_ENCRYPTION is set, it sets s3_server_side_encryption to the value symbolized" do
      mock_env = minimum_s3_env.merge({ "S3_ENCRYPTION" => "AES256" })
      options = Supermarket::S3Config.new("some_path", mock_env).to_paperclip_options
      expect(options[:s3_server_side_encryption]).to be :AES256
    end

    it "if CDN_URL is set, it sets s3 host aliasing" do
      mock_env = minimum_s3_env.merge({ "CDN_URL" => "somefqdn.example.com" })
      options = Supermarket::S3Config.new("some_path", mock_env).to_paperclip_options
      expect(options[:url]).to eq ":s3_alias_url"
      expect(options[:s3_host_alias]).to eq "somefqdn.example.com"
    end

    it "if static AWS credentials are set, it sets them in the options" do
      mock_env = minimum_s3_env.merge({
        "S3_ACCESS_KEY_ID" => "thisismyidtherearemanylikeitbutthisoneismine",
        "S3_SECRET_ACCESS_KEY" => "superdupersecret",
      })
      options = Supermarket::S3Config.new("some_path", mock_env).to_paperclip_options
      expect(options[:s3_credentials]).to eq({
        bucket: "bettergetabucket",
        s3_region: "over-yonder-1",
        access_key_id: "thisismyidtherearemanylikeitbutthisoneismine",
        secret_access_key: "superdupersecret",
      })
    end
  end
end
