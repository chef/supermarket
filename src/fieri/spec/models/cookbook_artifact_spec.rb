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

        expect(feedback).to match(/FC064/)
        expect(status).to be true
      end

      it 'does not include the working directory of the foodcritic run' do
        feedback, _status = artifact.criticize

        expect(feedback).to_not include(artifact.work_dir)
      end
    end

    describe '#binaries' do
      it 'returns an empty string' do
        binary_files = artifact.binaries

        expect(binary_files).to eq('')
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
        expect(feedback).to_not match(/FC031/)
        expect(feedback).to_not match(/FC045/)
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

        expect(feedback).to match(/FC064/)
        expect(status).to be true
      end
    end

    describe '#binaries' do
      it 'returns a list of binary files found in the cookbook' do
        binary_files = artifact.binaries

        expect(binary_files).to match(/fieri.tar.gz/)
      end

      it 'does not include the working directory of the binary check' do
        binary_files = artifact.binaries

        expect(binary_files).not_to match(/somejobid/)
      end
    end
  end
end
