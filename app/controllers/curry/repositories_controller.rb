class Curry::RepositoriesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :restrict_non_admin_access!

  #
  # GET /curry/repositories
  #
  # Displays the Curry::Repositories index
  #
  def index
    @repositories = Curry::Repository.all.sort_by(&:full_name)
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

    if subscriber.subscribe
      Curry::RepositorySubscriptionWorker.perform_async(repository.id)

      redirect_to curry_repositories_url,
                  notice: t('curry.repositories.subscribe.success')
    else
      @repository = subscriber.repository
      @repositories = Curry::Repository.all.sort_by(&:full_name)

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

  #
  # POST /curry/repositories/:id/evaluate
  #
  # Runs each open Pull Request in the repository through Curry's verification
  # process.
  #
  def evaluate
    repository = Curry::Repository.find(params[:id])

    Curry::RepositorySubscriptionWorker.perform_async(repository.id)

    notice = t('curry.repositories.evaluate', name: repository.full_name)

    redirect_to curry_repositories_url, notice: notice
  end

  private

  #
  # The permitted strong params for a repository.
  #
  def repository_params
    params.require(:curry_repository).permit(:full_name)
  end

  #
  # Render 404 if the current user is not an admin.
  # +not_found!+ comes from +ApplicationController+.
  #
  def restrict_non_admin_access!
    not_found! unless current_user.is?(:admin)
  end
end
