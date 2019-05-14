require 'spec_helper'

describe CookbookUpload::Archive do
  describe '#gzipped?' do
    it 'returns true if a tar file is GZipped' do
      tarball = described_class.new(File.new('spec/support/cookbook_fixtures/redis-test-v1.tgz'))
      expect(tarball.send(:gzipped?)).to be true
    end

    it 'fails if a tar file is not GZipped' do
      tarball = described_class.new(File.new('spec/support/cookbook_fixtures/not-actually-gzipped.tgz'))
      expect(tarball.send(:gzipped?)).to be false
    end
  end
end
