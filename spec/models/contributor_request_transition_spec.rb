require 'isolated_spec_helper'
require 'contributor_request_transition'

describe ContributorRequestTransition do
  it 'is successful if it is an authoritative acceptance' do
    transition = ContributorRequestTransition.accept(double, true)

    expect(transition).to be_successful
  end

  it 'is successful if it is an authoritative decline' do
    transition = ContributorRequestTransition.decline(double, true)

    expect(transition).to be_successful
  end

  it 'is successful if it is a redundant acceptance' do
    request = double('ContributorRequest', :accepted? => true)
    transition = ContributorRequestTransition.accept(request, false)

    expect(transition).to be_successful
  end

  it 'is successful if it is a redundant decline' do
    request = double('ContributorRequest', :accepted? => false, :declined? => true)
    transition = ContributorRequestTransition.decline(request, false)

    expect(transition).to be_successful
  end
end
