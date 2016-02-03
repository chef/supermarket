require 'spec_helper'

describe CookbookUpload::Metadata do
  describe 'setting the platforms attribute' do
    it 'fails loudly if Hash coercion fails' do
      expect do
        CookbookUpload::Metadata.new(platforms: '')
      end.to raise_error(Virtus::CoercionError)
    end

    it 'can coerce Arrays into Hashes' do
      metadata = CookbookUpload::Metadata.new(platforms: ['ubuntu'])

      expect(metadata.platforms).to eql('ubuntu' => nil)

      metadata = CookbookUpload::Metadata.new(platforms: ['ubuntu', '1.0.0'])

      expect(metadata.platforms).to eql('ubuntu' => nil, '1.0.0' => nil)
    end

    it 'accepts a Hash mapping Strings to Strings' do
      metadata = CookbookUpload::Metadata.new(platforms: { 'ubuntu' => 'cool' })

      expect(metadata.platforms).to eql('ubuntu' => 'cool')
    end

    describe 'setting the chef_version' do
      it 'sets the chef_version' do
        metadata = CookbookUpload::Metadata.new(chef_versions: [['12.4.1', '12.4.2'], ['11.2.3', '12.4.3']])
        expect(metadata.chef_versions).to eq([['12.4.1', '12.4.2'], ['11.2.3', '12.4.3']])
      end
    end

    describe 'setting the ohai_version' do
      it 'sets the ohai version' do
        metadata = CookbookUpload::Metadata.new(ohai_versions: [['8.8.1', '8.8.2'], ['8.9.1', '8.9.2']])
        expect(metadata.ohai_versions).to eq([['8.8.1', '8.8.2'], ['8.9.1', '8.9.2']])
      end
    end
  end
end
