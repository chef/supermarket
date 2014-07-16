class ToolsController < ApplicationController
  before_filter :authenticate_user!, except: [:index]

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
        tools_user_path(tool.user),
        notice: t('tool.created', name: tool.name)
      )
    else
      render :new
    end
  end

  #
  # This currently does nothing. It exists to make the form for adding a +Tool+
  # work. This will probably need to exist in a real way.
  #
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
