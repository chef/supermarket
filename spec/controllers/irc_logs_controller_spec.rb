require 'spec_helper'

describe IrcLogsController do
  describe 'GET #index' do
    it 'redirects to the botbot dashboard' do
      get :index

      expect(response).to redirect_to('https://botbot.me/dashboard/')
    end
  end
end
