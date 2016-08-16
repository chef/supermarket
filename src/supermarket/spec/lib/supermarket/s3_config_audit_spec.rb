require 'spec_helper'

describe Supermarket::S3ConfigAudit do
  context '#use_s3?' do
    it 'is true if required S3 configs are given in environment' do
      mock_env = {
        'S3_BUCKET' => 'bettergetabucket',
        'S3_ACCESS_KEY_ID' => 'thisismyidtherearemanylikeitbutthisoneismine',
        'S3_SECRET_ACCESS_KEY' => 'superdupersecret',
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
        'S3_BUCKET' => 'bettergetabucket',
        'S3_ACCESS_KEY_ID' => 'thisismyidtherearemanylikeitbutthisoneismine',
        'S3_SECRET_ACCESS_KEY' => 'superdupersecret'
      }
      expect { Supermarket::S3ConfigAudit.use_s3?(mock_env) }.to raise_exception Supermarket::S3ConfigAudit::IncompleteConfig
    end
  end
end
