shared_context 'env stashing' do
  let(:stash) { {} }

  before do
    stash.clear
    ENV.each do |k, v|
      stash[k] = v
      ENV[k] = nil
    end
  end

  after do
    stash.each { |k, v| ENV[k] = v }
  end
end
