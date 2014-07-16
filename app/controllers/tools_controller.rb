class ToolsController < ApplicationController
  before_filter :authenticate_user!, except: [:index]

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
  # POST /tools
  #
  # Create a new +Tool+
  #
  def create
    tool = current_user.tools.build(tool_params)

    if tool.save
      redirect_to(
        tools_user_path(tool.owner),
        notice: t('tool.created', name: tool.name)
      )
    else
      render :new
    end
  end

  private

  #
  # Strong params for a +Tool+
  #
  def tool_params
    params.require(:tool).permit(
      :name,
      :type,
      :description,
      :source_url,
      :instructions
    )
  end
end
