class CookbooksController < ApplicationController
  before_action :assign_cookbook, except: [:index, :directory, :available_for_adoption]
  before_action :store_location_then_authenticate_user!, only: [:follow, :unfollow, :adoption]

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
    @cookbooks = Cookbook.includes(:cookbook_versions).order(:deprecated)

    @current_params = cookbook_index_params

    if @current_params[:q].present?
      @cookbooks = @cookbooks.search(@current_params[:q]).with_pg_search_rank
    end

    if @current_params[:featured].present?
      @cookbooks = @cookbooks.featured
    end

    if @current_params[:order].present?
      @cookbooks = @cookbooks.ordered_by(@current_params[:order])
    end

    if @current_params[:order].blank? && @current_params[:q].blank?
      @cookbooks = @cookbooks.order(:name)
    end

    apply_filters @current_params

    @number_of_cookbooks = @cookbooks.count(:all)
    @cookbooks = @cookbooks.page(cookbook_index_params[:page]).per(20)

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
    @recently_updated_cookbooks = Cookbook
      .order_by_latest_upload_date
      .limit(5)
    @most_downloaded_cookbooks = Cookbook
      .includes(:cookbook_versions)
      .ordered_by("most_downloaded")
      .limit(5)
    @most_followed_cookbooks = Cookbook
      .includes(:cookbook_versions)
      .ordered_by("most_followed")
      .limit(5)
    @featured_cookbooks = Cookbook
      .includes(:cookbook_versions)
      .featured
      .order(:name)
      .limit(5)

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
    @collaborators = @cookbook.collaborators
    @supported_platforms = @cookbook.supported_platforms

    @public_metric_results = @latest_version.metric_results.open.sorted_by_name
    @admin_metric_results = @latest_version.metric_results.admin_only.sorted_by_name

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

    @cookbook.update(cookbook_urls_params)

    if cookbook_urls_params.key?(:up_for_adoption)
      if cookbook_urls_params[:up_for_adoption] == "true"
        AdoptionMailer.delay.follower_email(@cookbook)
      end
    end

    key = if cookbook_urls_params.key?(:up_for_adoption)
            if cookbook_urls_params[:up_for_adoption] == "true"
              "adoption.up"
            else
              "adoption.down"
            end
          else
            "cookbook.updated"
          end

    redirect_to @cookbook, notice: t(key, name: @cookbook.name)
  end

  #
  # PUT /cookbooks/:cookbook/follow
  #
  # Makes the current user follow the specified cookbook.
  #
  def follow
    @cookbook.cookbook_followers.create(user: current_user)
    Supermarket::Metrics.increment "cookbook.followed"

    render_follow_button
  end

  #
  # DELETE /cookbooks/:cookbook/unfollow
  #
  # Makes the current user unfollow the specified cookbook.
  #
  def unfollow
    cookbook_follower = @cookbook
      .cookbook_followers
      .where(user: current_user)
      .first!
    cookbook_follower.destroy
    Supermarket::Metrics.increment "cookbook.unfollowed"

    render_follow_button
  end

  #
  # PUT /cookbooks/:cookbook/deprecate
  #
  # Deprecates the cookbook, sets the replacement cookbook, kicks off a notifier
  # to send emails and redirects back to the deprecated cookbook.
  #
  def deprecate
    authorize! @cookbook

    replacement_cookbook_name = cookbook_deprecation_params[:cookbook][:replacement]

    if @cookbook.deprecate(replacement_cookbook_name)
      CookbookDeprecatedNotifier.perform_async(@cookbook.id)

      redirect_to(
        @cookbook,
        notice: t(
          "cookbook.deprecated",
          cookbook: @cookbook.name
        )
      )
    else
      redirect_to @cookbook, notice: @cookbook.errors.full_messages.join(", ")
    end
  end

  #
  # DELETE /cookbooks/:cookbook/deprecate
  #
  # Un-deprecates the cookbook and sets its replacement cookbook to nil.
  #
  def undeprecate
    authorize! @cookbook

    @cookbook.update(deprecated: false, replacement: nil)

    redirect_to(
      @cookbook,
      notice: t(
        "cookbook.undeprecated",
        cookbook: @cookbook.name
      )
    )
  end

  #
  # POST /cookbooks/:id/adoption
  #
  # Sends an email to the cookbook owner letting them know that someone is
  # interested in adopting their cookbook.
  #
  def adoption
    AdoptionMailer.delay.interest_email(@cookbook, current_user)

    redirect_to(
      @cookbook,
      notice: t(
        "adoption.email_sent",
        cookbook_or_tool: @cookbook.name
      )
    )
  end

  #
  # PUT /cookbooks/:cookbook/toggle_featured
  #
  # Allows a Supermarket admin to set a cookbook as featured or
  # unfeatured (if it is already featured).
  #
  def toggle_featured
    authorize! @cookbook

    @cookbook.update(featured: !@cookbook.featured)

    redirect_to(
      @cookbook,
      notice: t(
        "cookbook.featured",
        cookbook: @cookbook.name,
        state: @cookbook.featured? ? "featured" : "unfeatured"
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

  def available_for_adoption
    @available_cookbooks = Cookbook.where(up_for_adoption: true)
    @number_of_available_cookbooks = @available_cookbooks.count(:all)
  end

  private

  def assign_cookbook
    @cookbook ||= Cookbook.with_name(params[:id]).first!
  end

  def store_location_then_authenticate_user!
    store_location!(cookbook_path(@cookbook))
    authenticate_user!
  end

  def cookbook_index_params
    params.permit(:q, :featured, :order, :page, badges: [], platforms: [])
  end

  def cookbook_urls_params
    params.require(:cookbook).permit(:source_url, :issues_url, :up_for_adoption)
  end

  def cookbook_deprecation_params
    params.permit(cookbook: [:replacement])
  end

  def render_follow_button
    # In order to refresh the follower count the cookbook must be
    # reloaded before rendering.
    @cookbook.reload

    if params[:list].present?
      render partial: "follow_button_list", locals: { cookbook: @cookbook }
    else
      render partial: "follow_button_show", locals: { cookbook: @cookbook }
    end
  end

  def apply_filters(params)
    if params[:platforms].present? && params[:platforms][0].present?
      @cookbooks = @cookbooks.filter_platforms(params[:platforms])
    end

    if params[:badges].present? && params[:badges][0].present?
      @cookbooks = @cookbooks.filter_badges(params[:badges])
    end
  end
end
