class ToolsController < ApplicationController
  before_filter :store_location!, only: [:new]
  before_filter :authenticate_user!, except: [:index, :show, :directory]
  before_filter :assign_tool, only: [:show, :update, :edit, :destroy]
  before_filter :override_search

  #
  # GET /tools
  #
  # Lists all +Tool+ instances.
  #
  def index
    if params[:order] == 'created_at'
      @tools = Tool.order(:created_at)
    else
      @tools = Tool.order(:name)
    end

    if params[:q].present?
      @tools = @tools.search(params[:q])
    end

    if Tool::ALLOWED_TYPES.include?(params[:type])
      @tools = @tools.where(type: params[:type])
    end

    @tools = @tools.page(params[:page]).per(20)

    respond_to do |format|
      format.html
      format.atom
    end
  end

  #
  # GET /tools/new
  #
  # Display the form for creating a new +Tool+.
  #
  def new
    @tool = current_user.tools.new
    @user = current_user
  end

  #
  # GET /tools/:id
  #
  # Display the detail page for a +Tool+.
  #
  def show
    @other_tools = @tool.others_from_this_owner
    @collaborators = @tool.collaborators
  end

  #
  # POST /tools
  #
  # Create a new +Tool+
  #
  def create
    @tool = current_user.tools.build(tool_params)
    @user = current_user

    if @tool.save
      redirect_to(
        tools_user_path(@tool.owner),
        notice: t('tool.created', name: @tool.name)
      )
    else
      render :new
    end
  end

  #
  # GET /tools/:id/edit
  #
  # Display the form for editing an existing +Tool+.
  #
  def edit
    @user = current_user

    authorize! @tool
  end

  #
  # PATCH /tools/:id
  #
  # Updates an existing +Tool+.
  #
  def update
    @user = current_user

    authorize! @tool

    if @tool.update_attributes(tool_params)
      redirect_to(
        tools_user_path(@tool.owner),
        notice: t('tool.updated', name: @tool.name)
      )
    else
      render :edit
    end
  end

  #
  # DELETE /tools/:id
  #
  # Deletes a +Tool+.
  #
  def destroy
    authorize! @tool

    @tool.destroy
    redirect_to(
      tools_user_path(@tool.owner),
      notice: t('tool.deleted', name: @tool.name)
    )
  end

  #
  # GET /tools-directory
  #
  # Displays general information about tools and the most recently added ones.
  #
  def directory
    @recently_added_tools = Tool.ordered_by('recently_added').limit(5)
  end

  private

  #
  # Strong params for a +Tool+
  #
  def tool_params
    params.require(:tool).permit(
      :name,
      :slug,
      :type,
      :description,
      :source_url,
      :instructions
    )
  end

  #
  # Assigns a +Tool+ based on the slug.
  #
  def assign_tool
    @tool = Tool.find_by!(slug: params[:id])
  end

  #
  # Override the default search settings.
  #
  def override_search
    @search = { path: tools_path, name: 'Tools' }
  end
end
