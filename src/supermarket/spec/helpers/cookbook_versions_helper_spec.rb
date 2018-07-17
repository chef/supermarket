require 'spec_helper'

describe CookbookVersionsHelper do
  describe '#render_document' do
    it 'converts markdown to html when the extension is "md"' do
      expect(render_document('*hi*', 'md')).to eql("<p><em>hi</em></p>")
    end

    it 'returns the content if no extension is specified' do
      expect(render_document('_hi_', '')).to eql('_hi_')
    end
  end

  describe '#safe_updated_at' do
    it 'works if the collection has stuff in it' do
      expect(helper.safe_updated_at([create(:cookbook)])).to be <= Time.zone.now
    end

    it 'works if the collection is empty' do
      expect(helper.safe_updated_at([])).to be <= Time.zone.now
    end

    it 'works if the collection is nil' do
      expect(helper.safe_updated_at(nil)).to be <= Time.zone.now
    end
  end

  describe 'versions_string' do
    let(:chef_versions) { [['>= 12.4.1', '< 12.4.2'], ['> 11.2.3', '<= 12.4.3']] }
    let(:string) { helper.versions_string(chef_versions) }

    context 'combining the inner array elements' do
      it 'combines them with AND' do
        expect(string).to include('(>= 12.4.1 AND < 12.4.2)')
        expect(string).to include('(> 11.2.3 AND <= 12.4.3)')
      end
    end

    context 'combining the outer array elements' do
      it 'combines them with OR' do
        expect(string).to include('< 12.4.2) OR (> 11.2.3')
      end

      it 'does not include OR at the end of the string' do
        expect(string).to_not include('<= 12.4.3) OR')
      end
    end

    context 'with a single depth array' do
      # This is a bandaid until https://github.com/chef/supermarket/issues/1505
      context 'with one version' do
        let(:chef_versions) { ['>= 12.4.1'] }
        let(:string) { helper.versions_string(chef_versions) }

        it 'returns the version value as a string' do
          expect(string).to include('>= 12.4.1')
          expect(string.class).to eq(String)
        end
      end

      context 'with multiple versions' do
        let(:chef_versions) { ['>= 12.4.1', '12.5.2'] }
        let(:string) { helper.versions_string(chef_versions) }

        it 'combines them with AND' do
          expect(string).to include('>= 12.4.1 AND 12.5.2')
        end

        it 'does not include the AND at the end of the string' do
          expect(string).to_not include('12.5.2 AND')
        end
      end
    end
  end
end
