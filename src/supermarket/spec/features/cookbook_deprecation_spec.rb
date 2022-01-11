require "spec_helper"

feature "cookbook owners can deprecate a cookbook" do
  let(:cookbook) { create(:cookbook) }
  let(:replacement_cookbook) { create(:cookbook) }
  let(:user) { cookbook.owner }

  context "to just say DO NOT USE THIS" do
    before do
      sign_in(user)
      visit cookbook_path(cookbook)

      follow_relation "deprecate"

      within "#deprecate" do
        submit_form
      end
    end

    it "displays a success message" do
      expect_to_see_success_message
    end
  end

  context "with another cookbook to replace it" do
    before do
      sign_in(user)
      visit cookbook_path(cookbook)

      follow_relation "deprecate"

      within "#deprecate" do
        find(".cookbook-deprecate", visible: false).set(replacement_cookbook.name)
        submit_form
      end
    end

    it "displays a success message" do
      expect_to_see_success_message
    end

    it "displays a deprecation notice on the cookbook show with the replacment" do
      expect(page).to have_content(replacement_cookbook.name)
    end

    it "displays a deprecation notice on the cookbook partial with link to replacement" do
      visit user_path(cookbook.owner)

      expect(page).to have_content(replacement_cookbook.name)
    end

    context "when cookbook replacement is deleted" do
      before do
        replacement_cookbook.destroy
      end

      it "displays a simple deprecation notice on the cookbook show" do
        visit(current_path)

        expect(page).to_not have_content(replacement_cookbook.name)
      end

      it "displays a simple deprecation notice on the cookbook partial" do
        visit user_path(cookbook.owner)

        expect(page).to_not have_content(replacement_cookbook.name)
      end
    end
  end
end
