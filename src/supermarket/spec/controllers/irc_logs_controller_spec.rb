require 'spec_helper'

describe IrcLogsController do
  describe 'GET #index' do
    it 'redirects to the botbot dashboard' do
      get :index

      expect(response).to redirect_to('https://botbot.me/freenode/chef/')
    end
  end

  describe 'GET #show' do
    let(:botbot_base_url) { 'https://botbot.me/freenode/' }
    let(:github_repo_url) do
      'https://github.com/chef/irc_log_archives'
    end

    it 'redirects to the botbot channel if the date is not specified' do
      get :show, params: { channel: 'chef' }

      expect(response).to redirect_to(botbot_base_url + 'chef')
    end

    it 'redirects to botbot if the date is after August 8th, 2013' do
      get :show, params: { channel: 'chef', date: '2014-09-24' }

      expect(response).to redirect_to(botbot_base_url + 'chef/2014-09-24')
    end

    it 'redirects to the GitHub repo archive if the date is before August 8th, 2013' do
      get :show, params: { channel: 'chef', date: '2012-09-24' }

      expect(response).to redirect_to(github_repo_url)
    end

    it 'returns a 404 if an invalid date is given' do
      get :show, params: { channel: 'chef', date: '2012-08-' }

      expect(response.status).to eql(404)
    end
  end
end
