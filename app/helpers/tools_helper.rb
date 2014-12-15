module ToolsHelper
  #
  # Takes a tool type and returns a pretty version of it for display. This is
  # needed because DSC Resources are a special case that Rails' built-in
  # titleize doesn't handle.
  #
  # @param type [String] The tool type
  #
  # @return [String] The titleized tool type
  #
  def pretty_type(type)
    if type == 'dsc_resource'
      'DSC Resource'
    else
      type.titleize
    end
  end
end
