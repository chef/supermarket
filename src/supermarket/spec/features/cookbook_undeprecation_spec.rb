require "spec_helper"

feature "cookbook owners can undeprecate a cookbook" do
  let(:cookbook) { create(:cookbook, deprecated: true, replacement: create(:cookbook)) }
  let(:user) { cookbook.owner }

  before do
    sign_in(user)
    visit cookbook_path(cookbook)
    follow_relation "undeprecate"
  end

  it "displays a success message" do
    expect_to_see_success_message
  end

  it "it no longer displays a deprecation notice" do
    expect(page).to have_content("#{cookbook.name} is no longer deprecated.")
  end
end
