require 'octokit'

module Curry
  class RepositorySubscriber
    attr_reader :repository

    #
    # @param [Repository] repository An instance of +Curry::Repository+ that
    # is used for the Hubbub subscribing.
    #
    def initialize(repository)
      @repository = repository
    end

    #
    # Subscribes to the Repository's PubSubHubbub hub pull request events on
    # GitHub. GitHub will post to the specified hub_callback whenever a pull
    # request is opened, updated or closed.
    #
    # @param [String] callback_url The URL which should receive PubSubHubbub
    # callbacks.
    #
    # @return [TrueClass] if successfully subscribed
    # @return [FalseClass] if unable to subscribe
    #
    def subscribe!
      @repository.callback_url = pubsubhubbub_callback_url

      if @repository.valid?
        begin
          client.subscribe(
            topic,
            @repository.callback_url,
            ENV['PUBSUBHUBBUB_SECRET']
          )

          @repository.save
        rescue Octokit::Error => e
          @repository.errors.add(:base, e.message)

          false
        end
      end
    end

    #
    # Unsubscribes Supermarket from the repository.
    #
    # @return [Curry::Repository] if Supermarket has unsubscribed
    #
    # @raise [Octokit::Error] if unsubscribing from the hub fails
    #
    def unsubscribe!
      begin
        client.unsubscribe(topic, @repository.callback_url)
      rescue Octokit::UnprocessableEntity => e
        Rails.logger.info e
      end

      @repository.destroy
    end

    #
    # Resubscribes Supermarket to the repository, removing a webhook
    # on the repository for the recorded callback_url and resubscribing
    # to the repository with the current callback_url
    #
    # @return [Curry::Repository] if Supermarket has unsubscribed
    #
    # @raise [Octokit::Error] if unsubscribing from the hub fails
    #
    def resubscribe!
      begin
        client.unsubscribe(topic, @repository.callback_url)
        subscribe!
      rescue Octokit::UnprocessableEntity => e
        Rails.logger.info e
      end

      @repository
    end

    private

    #
    # Builds the topic URL based on the repository.
    #
    # @return [String] The Hubbub topic URL for subscribing to the pull request
    # event on the repository
    #
    def topic
      "https://github.com/#{@repository.owner}/#{@repository.name}/events/pull_request"
    end

    #
    # The Hubbub URL. By default it is computed from the protocol/host/port
    # settings in the environment so that callback from GitHub uses the public
    # URL of the Supermarket instance. Override the default by setting
    # PUBSUBHUBBUB_CALLBACK_URL in the environment (e.g. .env.<environment>)
    #
    # @return [String] The callback url for the GitHub PubSubHubbub hub to post
    #   from a subscribed repository's pull requests
    #
    def pubsubhubbub_callback_url
      ENV['PUBSUBHUBBUB_CALLBACK_URL'].presence || Rails.application.routes.url_helpers
        .url_for(controller: 'curry/pull_request_updates', action: 'create',
                 host: ENV['HOST'], protocol: ENV['PROTOCOL'], port: ENV['PORT'])
    end

    #
    # Initialize an Octokit::Client for make the subscribe request.
    #
    # @return [Octokit::Client] The Octokit Client that is authenticated with
    # the GitHub Access Token.
    def client
      Octokit::Client.new(
        access_token: ENV['GITHUB_ACCESS_TOKEN']
      )
    end
  end
end
