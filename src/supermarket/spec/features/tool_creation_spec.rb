require "spec_helper"

describe "creating a tool" do
  it "is possible for users to create a tool" do
    sign_in(create(:user))

    visit "/"
    follow_relation "view_profile"
    follow_relation "view_tools"
    follow_relation "add_tool"

    within ".tool_data" do
      fill_in "tool[name]", with: "butter"
      fill_in "tool[slug]", with: "butter"
      select "Knife Plugin", from: "tool[type]"
      fill_in "tool[description]", with: "Easily cut with knife"
      fill_in "tool[source_url]", with: "http://example.com"
      fill_in "tool[instructions]", with: "Delicious with toast."

      submit_form
    end

    expect_to_see_success_message
  end
end
