class ToolsController < ApplicationController
  #
  # GET /tools/new
  #
  # Display the form for creating a new +Tool+.
  #
  def new
    @tool = current_user.tools.new
  end

  def index
  end
end
