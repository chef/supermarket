module BuildCookbook
  module Helpers
    #########################################################################
    # Github
    #########################################################################
    def skip_omnibus_build?
      pr_has_label?('Omnibus: Skip Build')
    end
  end
end

Chef::Node.send(:include, BuildCookbook::Helpers)
Chef::Recipe.send(:include, BuildCookbook::Helpers)
Chef::Resource.send(:include, BuildCookbook::Helpers)
