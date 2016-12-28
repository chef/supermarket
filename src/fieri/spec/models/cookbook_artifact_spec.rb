require 'rails_helper'

describe CookbookArtifact do
  let(:artifact) { CookbookArtifact.new('http://example.com/apache.tar.gz', 'somejobid') }

  describe 'when checking cookbooks that have metadata.rb' do
    before do
      stub_request(:get, 'http://example.com/apache.tar.gz').
        to_return(
          body: File.open(File.expand_path('./spec/fixtures/apache.tar.gz')),
          status: 200
        )
    end

    describe '#initalize' do
      it 'assigns #url' do
        expect(artifact.url).to eq('http://example.com/apache.tar.gz')
      end

      it 'assigns #work_dir' do
        expect(artifact.work_dir).to eq(File.join(Dir.tmpdir, 'somejobid'))
      end
    end

    describe '#prep' do
      it 'prepares a unique directory for the job' do
        artifact.prep

        expect(Dir).to exist(artifact.work_dir)
      end
    end

    describe '#criticize' do
      it 'returns the feedback and status from the FoodCritic run' do
        feedback, status = artifact.criticize

        assert_match(/FC064/, feedback)
        assert_equal true, status
      end

      it 'does not include the working directory of the foodcritic run' do
        feedback, _status = artifact.criticize

        expect(feedback).to_not include(artifact.work_dir)
      end
    end

    describe '#clean' do
      it 'deletes the artifacts unarchived directory' do
        artifact.prep

        artifact.cleanup
        expect(Dir).not_to exist(artifact.work_dir)
      end
    end
  end

  describe 'when checking a cookbook that does not have metadata.rb' do
    let(:artifact) { CookbookArtifact.new('http://example.com/apache.tar.gz', 'somejobid2') }

    before do
      stub_request(:get, 'http://example.com/apache.tar.gz').
        to_return(
          body: File.open(File.expand_path('./spec/fixtures/apache-no-metadata.rb.tar.gz')),
          status: 200
        )
    end

    describe '#criticize' do
      it 'disables ~FC031 and ~FC045 by default' do
        feedback, _status = artifact.criticize
        refute_match(/FC031/, feedback)
        refute_match(/FC045/, feedback)
      end
    end
  end

  describe 'when checking a cookbook that must be read as binary' do
    let(:artifact) { CookbookArtifact.new('http://example.com/apache.tar.gz', 'somejobid2') }

    before do
      stub_request(:get, 'http://example.com/apache.tar.gz').
        to_return(
          body: File.open(File.expand_path('./spec/fixtures/apache-with-binaries.tar.gz')),
          status: 200
        )
    end

    describe '#criticize' do
      it 'disables ~FC031 and ~FC045 by default' do
        feedback, status = artifact.criticize

        assert_match(/FC064/, feedback)
        assert_equal true, status
      end
    end
  end
end
