class ToolsController < ApplicationController
  #
  # GET /tools/new
  #
  # Display the form for creating a new +Tool+.
  #
  def new
    @tool = current_user.tools.new
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
        tools_user_path(tool.user),
        notice: t('tool.created', name: tool.name)
      )
    else
      render :new
    end
  end

  def index
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
      :instructions,
      :user_id
    )
  end
end
