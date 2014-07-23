class CookbooksController < ApplicationController
  before_filter :assign_categories
  before_filter :assign_cookbook, only: [:show, :update, :follow, :unfollow, :transfer_ownership, :deprecate, :toggle_featured, :deprecate_search]
  before_filter :store_location_then_authenticate_user!, only: [:follow, :unfollow]

  #
  # GET /cookbooks
  #
  # Return all cookbooks. Cookbooks are sorted alphabetically by name.
  # Optionally a category can be specified to return only cookbooks for a
  # given category. Cookbooks can also be returned as an atom feed if the atom
  # format is specified.
  #
  # @example
  #   GET /cookbooks?q=redis
  #
  # Pass in order params to specify a sort order.
  #
  # @example
  #   GET /cookbooks?order=recently_updated
  #
  def index
    @cookbooks = Cookbook.includes(:cookbook_versions)

    if params[:q].present?
      @cookbooks = @cookbooks.search(params[:q])
    end

    if params[:featured].present?
      @cookbooks = @cookbooks.featured
    end

    if params[:order].present?
      @cookbooks = @cookbooks.ordered_by(params[:order])
    end

    if params[:order].blank? && params[:q].blank?
      @cookbooks = @cookbooks.order(:name)
    end

    @number_of_cookbooks = @cookbooks.count(:all)
    @cookbooks = @cookbooks.page(params[:page]).per(20)

    respond_to do |format|
      format.html
      format.atom
    end
  end

  #
  # GET /cookbooks/directory
  #
  # Return the three most recently updated and created cookbooks.
  #
  def directory
    @recently_updated_cookbooks = Cookbook.
      includes(:cookbook_versions).
      ordered_by('recently_updated').
      limit(5)
    @most_downloaded_cookbooks = Cookbook.
      includes(:cookbook_versions).
      ordered_by('most_downloaded').
      limit(5)
    @most_followed_cookbooks = Cookbook.
      includes(:cookbook_versions).
      ordered_by('most_followed').
      limit(5)
    @featured_cookbooks = Cookbook.
      includes(:cookbook_versions).
      featured.
      order(:name).
      limit(5)

    @cookbook_count = Cookbook.count
    @user_count = User.count
  end

  #
  # GET /cookbooks/:id
  #
  # Displays a cookbook.
  #
  def show
    @latest_version = @cookbook.latest_cookbook_version
    @cookbook_versions = @cookbook.sorted_cookbook_versions
    @owner = @cookbook.owner
    @collaborators = @cookbook.collaborators
    @supported_platforms = @cookbook.supported_platforms
    @owner_collaborator = CookbookCollaborator.new cookbook: @cookbook, user: @owner

    respond_to do |format|
      format.atom
      format.html
    end
  end

  #
  # GET /cookbooks/:id/download
  #
  # Redirects to the download location for the latest version of this cookbook.
  #
  def download
    cookbook = Cookbook.with_name(params[:id]).first!
    latest_version = cookbook.latest_cookbook_version
    redirect_to cookbook_version_download_url(cookbook, latest_version)
  end

  #
  # PATCH /cookbooks/:id
  #
  # Update a the specified cookbook. This currently only supports updating the
  # cookbook's URLs. It also only returns JSON.
  #
  # NOTE: :id must be the name of the cookbook.
  #
  def update
    authorize! @cookbook, :manage_cookbook_urls?

    @cookbook.update_attributes(cookbook_urls_params)

    redirect_to @cookbook
  end

  #
  # PUT /cookbooks/:cookbook/follow
  #
  # Makes the current user follow the specified cookbook.
  #
  def follow
    @cookbook.cookbook_followers.create(user: current_user)

    render_follow_button
  end

  #
  # DELETE /cookbooks/:cookbook/unfollow
  #
  # Makes the current user unfollow the specified cookbook.
  #
  def unfollow
    cookbook_follower = @cookbook.cookbook_followers.
      where(user: current_user).first!
    cookbook_follower.destroy

    render_follow_button
  end

  #
  # PUT /cookbooks/:cookbook/transfer_ownership
  #
  # Transfers ownership of cookbook to another user and redirects
  # back to the cookbook.
  #
  def transfer_ownership
    authorize! @cookbook
    @cookbook.update_attributes(transfer_ownership_params)
    redirect_to @cookbook, notice: t('cookbook.transfered_ownership', cookbook: @cookbook.name, user: @cookbook.owner.username)
  end

  #
  # PUT /cookbooks/:cookbook/deprecate
  #
  # Deprecates the cookbook, sets the replacement cookbook, kicks off a notifier
  # to send emails and redirects back to the deprecated cookbook.
  #
  def deprecate
    authorize! @cookbook

    replacement_cookbook = Cookbook.with_name(
      cookbook_deprecation_params[:replacement]
    ).first!

    if @cookbook.deprecate(replacement_cookbook)
      CookbookDeprecatedNotifier.perform_async(@cookbook.id)

      redirect_to(
        @cookbook,
        notice: t(
          'cookbook.deprecated',
          cookbook: @cookbook.name,
          replacement_cookbook: replacement_cookbook.name
        )
      )
    else
      redirect_to(
        @cookbook,
        notice: t(
          'cookbook.deprecate_failure',
          cookbook: @cookbook.name
        )
      )
    end
  end

  #
  # PUT /cookbooks/:cookbook/toggle_featured
  #
  # Allows a Supermarket admin to set a cookbook as featured or
  # unfeatured (if it is already featured).
  #
  def toggle_featured
    authorize! @cookbook

    @cookbook.update_attribute(:featured, !@cookbook.featured)

    redirect_to(
      @cookbook,
      notice: t(
        'cookbook.featured',
        cookbook: @cookbook.name,
        state: "#{@cookbook.featured? ? 'featured' : 'unfeatured'}"
      )
    )
  end

  # GET /cookbooks/:id/deprecate_search?q=QUERY
  #
  # Return cookbooks with a name that contains the specified query. Takes the
  # +q+ parameter for the query. Only returns cookbook elgible for replacement -
  # cookbooks that are not deprecated and not the cookbook being deprecated.
  #
  # @example
  #   GET /cookbooks/redis/deprecate_search?q=redisio
  #
  def deprecate_search
    @results = @cookbook.deprecate_search(params.fetch(:q, nil))

    respond_to do |format|
      format.json
    end
  end

  private

  def assign_categories
    @categories ||= Category.all
  end

  def assign_cookbook
    @cookbook ||= Cookbook.with_name(params[:id]).first!
  end

  def store_location_then_authenticate_user!
    store_location!(cookbook_path(@cookbook))
    authenticate_user!
  end

  def cookbook_urls_params
    params.require(:cookbook).permit(:source_url, :issues_url)
  end

  def transfer_ownership_params
    params.require(:cookbook).permit(:user_id)
  end

  def cookbook_deprecation_params
    params.require(:cookbook).permit(:replacement)
  end

  def render_follow_button
    # In order to refresh the follower count the cookbook must be
    # reloaded before rendering.
    @cookbook.reload

    if params[:list].present?
      render partial: 'follow_button_list', locals: { cookbook: @cookbook }
    else
      render partial: 'follow_button_show', locals: { cookbook: @cookbook }
    end
  end
end
