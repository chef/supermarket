require 'spec_helper'

describe Curry::Repository do
  context 'validations' do
    it { should validate_presence_of(:owner) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:callback_url) }
  end

  it "deletes the repository's pull requests when destroyed" do
    repository = create(:repository)
    pull_request = create(:pull_request, repository: repository)

    expect do
      repository.destroy
    end.to change(Curry::PullRequest, :count).by(-1)
  end

  it 'assigns name and owner based on full_name' do
    repository = Curry::Repository.new(full_name: 'chef/supermarket')

    expect(repository.owner).to eql('chef')
    expect(repository.name).to eql('supermarket')
  end

  describe '#subscribe!' do
    let!(:cached_fqdn) { ENV['FQDN'] }
    let(:expected_fqdn) { 'bunniesareadorable' }

    before do
      ENV['FQDN'] = expected_fqdn
      expect(ENV['FQDN']).to eq(expected_fqdn)
    end

    it 'sets the correct callback_url' do
      repository = Curry::Repository.new(full_name: 'chef/supermarket')

      expect(repository.callback_url).to be_nil

      repository_subscriber = Curry::RepositorySubscriber.new(repository)
      repository_subscriber.subscribe!

      expect(repository.callback_url).to eq("http://#{expected_fqdn}:3000/curry/pull_request_updates")
    end

    after do
      ENV['FQDN'] = cached_fqdn
      expect(ENV['FQDN']).to eq(cached_fqdn)
    end
  end
end
