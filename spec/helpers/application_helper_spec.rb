require 'spec_helper'

describe ApplicationHelper do
  describe '#auth_path' do
    context 'when using a symbol' do
      it 'returns the correct path' do
        expect(auth_path(:github)).to eq('/auth/github')
      end
    end

    context 'when using a string' do
      it 'returns the correct path' do
        expect(auth_path('github')).to eq('/auth/github')
      end
    end
  end

  describe '#posessivize' do
    it "should end in 's if the name does not end in s" do
      expect(posessivize('Black')).to eql "Black's"
    end

    it "should end in ' if the name ends in s" do
      expect(posessivize('Volkens')).to eql "Volkens'"
    end

    it 'should return an empty string when passed one' do
      expect(posessivize('')).to eql ''
    end

    it 'should return nil when passed nil' do
      expect(posessivize(nil)).to be_nil
    end
  end

  describe '#flash_message_class_for' do
    it 'should return a flass message class for notice flash messages' do
      expect(flash_message_class_for('notice')).to eql('success')
    end

    it 'should return a flass message class for alert flash messages' do
      expect(flash_message_class_for('alert')).to eql('alert')
    end

    it 'should return a flass message class for warning flash messages' do
      expect(flash_message_class_for('warning')).to eql('warning')
    end
  end

  describe '#search_path' do
    context 'when using the contributors controller' do
      it 'returns the contributors path' do
        expect(search_path('contributors')).to eq(contributors_path)
      end
    end

    context 'when using the icla signatures controller' do
      it 'returns the icla signatures path' do
        expect(search_path('icla_signatures')).to eq(icla_signatures_path)
      end
    end

    context 'when using the ccla signatures controller' do
      it 'returns the ccla signatures path' do
        expect(search_path('ccla_signatures')).to eq(ccla_signatures_path)
      end
    end
  end

  describe '#search_field_text' do
    context 'when using the contributors controller' do
      it 'returns the contributors search text' do
        expect(search_field_text('contributors')).to eq('Search for a contributor by name, email, chef or github username')
      end
    end

    context 'when using the icla signatures controller' do
      it 'returns the icla signatures search text' do
        expect(search_field_text('icla_signatures')).to eq('Search for an ICLA signer by name or email')
      end
    end

    context 'when using the ccla signatures controller' do
      it 'returns the ccla signatures search text' do
        expect(search_field_text('ccla_signatures')).to eq('Search for a CCLA signer by company name')
      end
    end
  end
end
