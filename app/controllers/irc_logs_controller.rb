class IrcLogsController < ApplicationController
  #
  # GET /chat
  #
  # Redirects to the botbot.me dashboard (list of IRC channels).
  #
  def index
    redirect_to('https://botbot.me/dashboard/')
  end
end
