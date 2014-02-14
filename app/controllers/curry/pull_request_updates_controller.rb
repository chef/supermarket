require 'openssl'

class Curry::PullRequestUpdatesController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_filter :verify_github_signature, unless: -> { Rails.env.development? }
  before_filter :find_pull_request!

  #
  # POST /curry/pull_request_updates
  #
  # Creates a new PullRequestUpdate
  #
  def create
    pull_request_update = Curry::PullRequestUpdate.create(
      pull_request_update_params
    )

    if pull_request_update.persisted? && !pull_request_update.closing?
      Curry::ImportUnknownPullRequestCommitAuthorsWorker.perform_async(
        pull_request_update.pull_request.id
      )
    end

    head(200)
  end

  private

  #
  # GitHub's PubSubHubbub callback parameters, adapted to match
  # Curry::PullRequestUpdate attributes
  #
  # @return [Hash] pull request update attributes
  #
  def pull_request_update_params
    {
      pull_request: pull_request,
      action: payload.fetch('action')
    }
  end

  #
  # Ensure that GitHub's payload corresponds to a Curry::Repository and a
  # Curry::PullRequest on that repository
  #
  # @raise [ActiveRecord::RecordNotFound] if the repository is not being
  #   tracked by Curry
  #
  def find_pull_request!
    owner, name = payload.fetch('repository').fetch('full_name').split('/')

    repository = Curry::Repository.find_by!(owner: owner, name: name)

    number = payload.fetch('number')

    @pull_request = repository.pull_requests.numbered(number).first_or_create
  end

  #
  # The PubSubHubbub payload sent from GitHub
  #
  # @return [Hash]
  #
  def payload
    JSON.parse(params.require(:payload))
  end

  #
  # Verify the X-Hub-Signature header, and respond with a 400 if it cannot be
  # verified
  #
  def verify_github_signature
    if github_signature != expected_signature
      head 400
    end
  end

  def github_signature
    if request.headers['X-Hub-Signature']
      request.headers['X-Hub-Signature'].split('=').last
    end
  end

  def expected_signature
    OpenSSL::HMAC.hexdigest(
      HMAC_DIGEST,
      Supermarket::Config.pubsubhubbub.fetch('hub_secret'),
      request.body.read
    )
  end

  attr_reader :pull_request

  HMAC_DIGEST = OpenSSL::Digest::Digest.new('sha1')

end
