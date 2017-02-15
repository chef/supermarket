shared_examples 'an API v1 controller' do
  context '#item_limit' do
    it 'knows the API item limit' do
      subject.respond_to?(:item_limit)
    end

    it 'determines the API item limit from an environment variable' do
      expect(ENV).to receive(:[]).with('API_ITEM_LIMIT').and_return(9999)
      expect(subject.send(:item_limit)).to eql(9999)
    end

    it 'defaults to 100 if there is no environment variable set' do
      expect(ENV).to receive(:[]).with('API_ITEM_LIMIT').and_return(nil)
      expect(subject.send(:item_limit)).to eql(100)
    end

    it 'defaults to 100 if set to something other than a positive integer' do
      expect(ENV).to receive(:[]).with('API_ITEM_LIMIT').and_return('nope, not an integer')
      expect(subject.send(:item_limit)).to eql(100)
    end
  end
end
