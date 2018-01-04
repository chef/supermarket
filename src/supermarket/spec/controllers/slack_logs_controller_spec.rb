require 'spec_helper'

describe SlackLogsController do
  describe 'GET #index' do
    it 'redirects to the slack archive' do
      get :index

      expect(response).to redirect_to('https://chefcommunity.slackarchive.io')
    end
  end
end
