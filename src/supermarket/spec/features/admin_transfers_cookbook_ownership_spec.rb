require "spec_helper"

feature "admin transfers cookbook ownership" do
  let(:cookbook) { create(:cookbook) }
  let(:new_owner) { create(:user) }

  before do
    sign_in(create(:admin))
    visit cookbook_path(cookbook)
    follow_relation "transfer_ownership"

    within "#transfer" do
      find(".collaborators", visible: false).set(new_owner.id)
      submit_form
    end
  end

  it "displays a success message" do
    expect_to_see_success_message
  end

  it "changes the owner" do
    expect(page).to have_content(new_owner.username)
  end
end
