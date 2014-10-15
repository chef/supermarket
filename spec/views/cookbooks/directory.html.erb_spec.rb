require 'spec_helper'

describe 'cookbooks/directory.html.erb' do
  before do
    assign(:featured_cookbooks, [])
    assign(:recently_updated_cookbooks, [])
    assign(:most_downloaded_cookbooks, [])
    assign(:most_followed_cookbooks, [])
  end

  it_behaves_like 'community stats'
end
