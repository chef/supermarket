require 'spec_helper'

feature 'Curry', type: :request do
  scenario 'pull request webhook handler reports that it is Gone' do
    post '/curry/pull_request_updates'

    expect(response.status.to_i).to eql(410)
  end
end
