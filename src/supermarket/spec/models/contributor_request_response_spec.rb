require 'spec_helper'

describe ContributorRequestResponse do
  context 'validations' do
    before do
      ContributorRequestResponse.create!(
        decision: 'accepted',
        contributor_request_id: 0
      )
    end

    it { should validate_uniqueness_of(:contributor_request_id) }
    it { should validate_presence_of(:contributor_request_id) }
    it { should validate_inclusion_of(:decision).in_array(%w(accepted declined)) }
  end

  describe '.accept!' do
    it 'creates a record with a decision of "accepted"' do
      contributor_request = create(:contributor_request)

      response = ContributorRequestResponse.accept!(contributor_request)

      expect(response.contributor_request_id).to eql(contributor_request.id)
      expect(response.decision).to eql('accepted')
    end
  end

  describe '.decline!' do
    it 'creates a record with a decision of "declined"' do
      contributor_request = create(:contributor_request)

      response = ContributorRequestResponse.decline!(contributor_request)

      expect(response.contributor_request_id).to eql(contributor_request.id)
      expect(response.decision).to eql('declined')
    end
  end

  describe '#affirmative?' do
    it 'is true when the response is "accepted"' do
      contributor_request_response = ContributorRequestResponse.new(
        decision: 'accepted'
      )

      expect(contributor_request_response).to be_affirmative
    end

    it 'is false when the response is "declined"' do
      contributor_request_response = ContributorRequestResponse.new(
        decision: 'declined'
      )

      expect(contributor_request_response).to_not be_affirmative
    end
  end

  describe '#negative?' do
    it 'is false when the response is "accepted"' do
      contributor_request_response = ContributorRequestResponse.new(
        decision: 'accepted'
      )

      expect(contributor_request_response).to_not be_negative
    end

    it 'is true when the response is "declined"' do
      contributor_request_response = ContributorRequestResponse.new(
        decision: 'declined'
      )

      expect(contributor_request_response).to be_negative
    end
  end
end
