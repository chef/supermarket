class SlackLogsController < ApplicationController
  #
  # GET /chat
  #
  # Redirects to the Chef commuity slack archive.
  #
  def index
    redirect_to('https://chefcommunity.slackarchive.io')
  end
end
