class IrcLogsController < ApplicationController
  #
  # GET /chat
  #
  # Redirects to the botbot.me dashboard (list of IRC channels).
  #
  def index
    redirect_to("https://botbot.me/freenode/chef/", allow_other_host: true)
  end

  #
  # GET /chat/:channel/:date
  #
  # Redirects to the botbot.me channel log if the date is August 8th, 2013 or
  # later (that is the first known day of botbot.me logging the IRC chat).
  #
  # Redirects to the GitHub repo of IRC logs stored in the previous community
  # site if the date is before August 8th, 2013.
  #
  # If no date is specified (just the channel name) or the date that cannot be
  # parsed with +Date.parse+, redirect to that botbot.me channel.
  #
  # @example
  #
  #   GET /chat/chef/2014-09-24
  #
  def show
    botbot_base_url = "https://botbot.me/freenode/"
    github_repo_url = "https://github.com/chef/irc_log_archives"

    channel = params[:channel]
    date_str = params.fetch(:date, nil)

    begin
      date = Date.parse(date_str) unless date_str.nil?
    rescue ArgumentError
      not_found!
    else
      cutoff_date = Date.parse("2013-08-08")

      if date_str.nil?
        redirect_to(botbot_base_url + channel, allow_other_host: true)
      elsif date > cutoff_date
        redirect_to(botbot_base_url + channel + "/" + date_str, allow_other_host: true)
      else
        redirect_to(github_repo_url, allow_other_host: true)
      end
    end
  end
end
