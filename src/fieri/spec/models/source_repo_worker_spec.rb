require 'rails_helper'

describe SourceRepoWorker do
  context 'when source_url is present and not null' do
    context 'and source_url is a GitHub URL' do
      let(:cookbook_json) { File.read('spec/support/cookbook_source_url_fixture.json') }

      it 'retrieves the source_url from the JSON API response' do
        expect(subject.send(:source_repo_url, cookbook_json)).to eq('http://github.com/johndoe/example_repo')
      end

      it 'can determine a GitHub repo name' do
        expect(subject.send(:source_repo, cookbook_json)).to eq('johndoe/example_repo')
      end
    end

    context 'and source_url is a URL somewhere other than GitHub' do
      let(:some_other_source_site) { '{"source_url": "https://example_repo.codeplex.com"}' }

      it 'retrieves the source_url' do
        expect(subject.send(:source_repo_url, some_other_source_site)).to eq('https://example_repo.codeplex.com')
      end

      it 'returns and empty repo name' do
        expect(subject.send(:source_repo, some_other_source_site)).to eq('')
      end
    end
  end

  context 'when a source_url is present but value is null' do
    let(:null_source_url) { File.read('spec/support/cookbook_null_source_url_fixture.json') }

    it 'returns an empty source_url' do
      expect(subject.send(:source_repo_url, null_source_url)).to eq('')
    end

    it 'returns an empty repo name' do
      expect(subject.send(:source_repo, null_source_url)).to eq('')
    end
  end

  it 'does not bomb when the source_url is not present' do
    expect(subject.send(:source_repo_url, '{}')).to eq('')
    expect(subject.send(:source_repo, '{}')).to eq('')
  end
end
