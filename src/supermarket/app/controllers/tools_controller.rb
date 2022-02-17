class ToolsController < ApplicationController
  before_action :store_location!, only: [:new]
  before_action :authenticate_user!, except: [:index, :show, :directory]
  before_action :assign_tool, only: [:show, :update, :edit, :destroy, :adoption]
  before_action :override_search

  #
  # GET /tools
  #
  # Lists all +Tool+ instances.
  #
  def index
    @current_params = tool_index_params

    @tools = if @current_params[:order] == "created_at"
               Tool.order(:created_at)
             else
               Tool.order(:name)
             end

    if @current_params[:q].present?
      @tools = @tools.search(@current_params[:q])
    end

    if Tool::ALLOWED_TYPES.include?(@current_params[:type])
      @tools = @tools.where(type: @current_params[:type])
    end

    @tools = @tools.page(@current_params[:page]).per(20)

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
        notice: t("tool.created", name: @tool.name)
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

    if @tool.update(tool_params)
      key = if tool_params.key?(:up_for_adoption)
              if tool_params[:up_for_adoption] == "true"
                "adoption.up"
              else
                "adoption.down"
              end
            else
              "tool.updated"
            end

      redirect_to(
        tool_path(@tool),
        notice: t(key, name: @tool.name)
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
      notice: t("tool.deleted", name: @tool.name)
    )
  end

  #
  # GET /tools-directory
  #
  # Displays general information about tools and the most recently added ones.
  #
  def directory
    @recently_added_tools = Tool.ordered_by("recently_added").limit(5)
  end

  #
  # POST /tools/:id/adoption
  #
  # Sends an email to the tool owner letting them know that someone is
  # interested in adopting their tool.
  #
  def adoption
    AdoptionMailer.delay.interest_email(@tool.id, @tool.class.name, current_user.id)

    redirect_to(
      @tool,
      notice: t(
        "adoption.email_sent",
        cookbook_or_tool: @tool.name
      )
    )
  end

  private

  def tool_index_params
    params.permit(:q, :order, :type, :page)
  end

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
      :instructions,
      :up_for_adoption
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
    @search = { path: tools_path, name: "Tools" }
  end
end
