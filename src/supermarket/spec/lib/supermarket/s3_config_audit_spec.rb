require 'spec_helper'

describe Supermarket::S3ConfigAudit do
  context '#use_s3?' do
    it 'is true if required S3 configs are given in environment' do
      mock_env = {
        'S3_BUCKET' => 'bettergetabucket',
        'S3_REGION' => 'over-yonder-1'
      }
      expect(Supermarket::S3ConfigAudit.use_s3?(mock_env)).to be true
    end

    it 'is false if no required S3 configs are given in the environment' do
      mock_env = {}
      expect(Supermarket::S3ConfigAudit.use_s3?(mock_env)).to be false
    end

    it 'throws an exception if some but not all of the required S3 configs are present' do
      mock_env = {
        'S3_BUCKET' => 'bettergetabucket'
      }
      expect { Supermarket::S3ConfigAudit.use_s3?(mock_env) }.to raise_exception Supermarket::S3ConfigAudit::IncompleteConfig
    end

    it 'throws an exception if any of the required S3 configs are blank' do
      mock_env = {
        'S3_BUCKET' => '',
        'S3_REGION' => ''
      }
      expect { Supermarket::S3ConfigAudit.use_s3?(mock_env) }.to raise_exception Supermarket::S3ConfigAudit::IncompleteConfig
    end
  end

  context '#use_s3_with_static_creds?' do
    it 'is true if both S3_ACCESS_KEY_ID and S3_SECRET_ACCESS_KEY are present' do
      mock_env = {
        'S3_ACCESS_KEY_ID' => 'thisismyidtherearemanylikeitbutthisoneismine',
        'S3_SECRET_ACCESS_KEY' => 'superdupersecret'
      }
      expect(Supermarket::S3ConfigAudit.use_s3_with_static_creds?(mock_env)).to be true
    end

    it 'is false if S3_ACCESS_KEY_ID and S3_SECRET_ACCESS_KEY are absent' do
      mock_env = {}
      expect(Supermarket::S3ConfigAudit.use_s3_with_static_creds?(mock_env)).to be false
    end

    it 'throws an exception if only S3_ACCESS_KEY_ID or only S3_SECRET_ACCESS_KEY is present' do
      mock_env = {
        'S3_ACCESS_KEY_ID' => 'thisismyidtherearemanylikeitbutthisoneismine'
      }
      expect { Supermarket::S3ConfigAudit.use_s3_with_static_creds?(mock_env) }.to raise_exception Supermarket::S3ConfigAudit::IncompleteConfig
    end

    it 'throws an exception if S3_ACCESS_KEY_ID or S3_SECRET_ACCESS_KEY is an empty string' do
      mock_env = {
        'S3_ACCESS_KEY_ID' => '',
        'S3_SECRET_ACCESS_KEY' => ''
      }
      expect { Supermarket::S3ConfigAudit.use_s3_with_static_creds?(mock_env) }.to raise_exception Supermarket::S3ConfigAudit::IncompleteConfig
    end
  end
end
