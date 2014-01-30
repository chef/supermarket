class Curry::RepositoriesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :restrict_non_admin_access!

  #
  # GET /curry/repositories
  #
  # Displays the Curry::Repositories index
  #
  def index
    @repositories = Curry::Repository.all
    @repository = Curry::Repository.new
  end

  #
  # POST /curry/repositories
  #
  # Subscribes to a new Repository
  #
  def create
    repository = Curry::Repository.new(repository_params)
    subscriber = Curry::RepositorySubscriber.new(repository)

    if subscriber.subscribe(pubsubhubbub_callback_url)
      redirect_to curry_repositories_url,
        notice: t('curry.repositories.subscribe.success')
    else
      @repository = subscriber.repository
      @repositories = Curry::Repository.all

      flash.now[:alert] = t('curry.repositories.subscribe.failure')

      render :index
    end
  end

  #
  # DELETE /curry/repositories/:id
  #
  # Deletes the repository record and unsubscribes Supermarket from the GitHub repository's Hubbub hub.
  #
  def destroy
    subscriber = Curry::RepositorySubscriber.new(
      Curry::Repository.find(params[:id])
    )

    if subscriber.unsubscribe
      flash[:notice] = t('curry.repositories.unsubscribe.success')
    else
      flash[:alert] = t('curry.repositories.unsubscribe.failure')
    end

    redirect_to curry_repositories_url
  end

  private

  #
  # The permitted strong params for a repository.
  #
  def repository_params
    params.require(:curry_repository).permit(:owner, :name)
  end

  #
  # Render 404 if the current user is not an admin.
  # +not_found!+ comes from +ApplicationController+.
  #
  def restrict_non_admin_access!
    not_found! unless current_user.is?(:admin)
  end

  #
  # The Hubbub URL. It is configured in application.yml. If it is not present,
  # then use the +curry_pull_request_updates_url+ route.
  #
  # @return [String] The callback url for the GitHub PubSubHubbub hub to post
  #   from a subscribed repository's pull requests
  #
  def pubsubhubbub_callback_url
    if Supermarket::Config.pubsubhubbub['callback_url'].blank?
      curry_pull_request_updates_url
    else
      Supermarket::Config.pubsubhubbub['callback_url']
    end
  end
end
