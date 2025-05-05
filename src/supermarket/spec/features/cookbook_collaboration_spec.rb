require "spec_helper"

describe "cookbook collaboration" do
  let(:suzie) { create(:user) }
  let(:sally) { create(:user) }
  let(:cookbook) { create(:cookbook, owner: sally) }

  before do
    create(:cookbook_collaborator, resourceable: cookbook, user: suzie)
  end

  def navigate_to_cookbook
    visit "/"
    follow_relation "cookbooks"

    within ".recently-updated" do
      follow_relation "cookbook"
    end
  end

  it "allows the owner to remove a collaborator", use_playwright: true do
    sign_in(sally)
    navigate_to_cookbook

    find("[rel*=remove-cookbook-collaborator]").trigger("click")
    expect(page).to have_no_css("div.gravatar-container")
  end

  it "allows a collaborator to remove herself", use_playwright: true do
    sign_in(suzie)
    navigate_to_cookbook

    find("[rel*=remove-cookbook-collaborator]").trigger("click")
    expect(page).to have_no_css("div.gravatar-container")
  end

  context "adding groups of collaborators" do
    let!(:admin_group_member) { create(:group_member, admin: true, user: sally) }
    let!(:group) { admin_group_member.group }
    let!(:non_admin_user) { create(:user, first_name: "Jon", last_name: "Snow") }
    let!(:non_admin_group_member) { create(:group_member, group: group, user: non_admin_user) }

    before do
      sign_in(sally)

      expect(group.group_members).to include(admin_group_member, non_admin_group_member)
    end

    context "when the collaborator_groups feature is not active" do
      before do
        Feature.deactivate(:collaborator_groups)
        expect(Feature.active?(:collaborator_groups)).to eq(false)
      end

      it "does not show the groups field" do
        navigate_to_cookbook
        find("#manage").click
        find("[rel*=add-collaborator]").click
        expect(page).to_not have_content("Groups")
      end
    end

    context "when the collaborator groups feature is active" do
      before do
        Feature.activate(:collaborator_groups)
        expect(Feature.active?(:collaborator_groups)).to eq(true)
        navigate_to_cookbook
        find("#manage").click
        find("[rel*=add-collaborator]").click
        find(".groups", visible: false).set(group.id)

        click_button("Add")
      end

      it "shows the group name" do
        expect(page).to have_link(group.name)
      end

      it "allows the owner to add a group of collaborators" do
        expect(page).to have_link("#{admin_group_member.user.first_name} #{admin_group_member.user.last_name}", href: user_path(admin_group_member.user))
        expect(page).to have_link("#{non_admin_group_member.user.first_name} #{non_admin_group_member.user.last_name}", href: user_path(non_admin_group_member.user))
      end

      context "when a member is added to the group" do
        let(:existing_user) { create(:user) }

        before do
          visit group_path(group)
          click_link("Add Group Member")
          find(:xpath, "//input[@id='user_ids']", visible: false).set existing_user.id.to_s
          click_button("Add Member")
          navigate_to_cookbook
        end

        it "adds the member as a contributor to the cookbook" do
          expect(page).to have_link("#{existing_user.first_name} #{existing_user.last_name}", href: user_path(existing_user))
        end

        context "when a member is removed from a group" do
          before do
            visit group_path(group)
          end

          it "removes the member as a contributor on the cookbook" do
            within("ul#members") do
              click_link("Remove", match: :first)
            end

            navigate_to_cookbook
            expect(page).to_not have_link("#{non_admin_group_member.user.first_name} #{non_admin_group_member.user.last_name}", href: user_path(non_admin_group_member.user))
          end
        end
      end

      context "removing groups of collaborators" do
        before do
          click_link("Remove")
        end

        it "removes the group name from the cookbook page" do
          expect(page).to_not have_link(group.name)
        end

        it "removes the group members as collaborators" do
          # NOTE: The admin_group_member is also the owner of the cookbook, and therefore will remain on the page as the owner
          expect(page).to_not have_link("#{non_admin_group_member.user.first_name} #{non_admin_group_member.user.last_name}", href: user_path(non_admin_group_member.user))
        end
      end

      context "when a user is already a collaborator with another group" do
        context "adding the group" do
          let!(:admin_group_member_2) { create(:group_member, admin: true, user: sally) }
          let!(:group_2) { admin_group_member_2.group }
          let!(:non_admin_group_member_2) { create(:group_member, group: group_2, user: non_admin_user) }

          before do
            navigate_to_cookbook
            expect(page).to have_link(group.name)
            find("#manage").click
            find("[rel*=add-collaborator]").click
            find(".groups", visible: false).set(group_2.id)
            click_button("Add")
          end

          it "adds the second group" do
            expect(page).to have_link(group_2.name)
          end

          it "adds the user as a second collaborator associated with group_2" do
            expect(non_admin_group_member_2.user).to eq(non_admin_group_member.user)
            expect(page).to have_link("#{non_admin_group_member_2.user.first_name} #{non_admin_group_member_2.user.last_name}", href: user_path(non_admin_group_member_2.user), count: 2)
          end

          context "removing the group" do
            before do
              resource = GroupResource.where(resourceable_id: cookbook.id, group: group_2).first
              # Finds the correct "Remove Group" link associated with group_2
              find("a[href=\"#{destroy_group_collaborator_path(resourceable_type: resource.resourceable_type, resourceable_id: resource.resourceable_id, id: resource.group)}\"]").click
            end

            it "removes the second collaborator" do
              expect(page).to have_link("#{non_admin_group_member_2.user.first_name} #{non_admin_group_member_2.user.last_name}", href: user_path(non_admin_group_member_2.user), count: 1)
            end

            it "shows a warning that the user is still a collaborator associated with another group" do
              expect(page).to have_content("#{non_admin_group_member_2.user.username} is still a collaborator associated with #{group.name}")
            end
          end
        end
      end

      context "when a user is already a collaborator NOT affiliated with a group" do
        let(:new_user) { create(:user, first_name: "Already", last_name: "Collab") }

        before do
          navigate_to_cookbook

          find("#manage").click
          find("[rel*=add-collaborator]").click
          find(".collaborators.multiple", visible: false).set(new_user.id)

          click_button("Add")
        end

        context "adding a group" do
          let!(:new_admin_member) { create(:group_member, admin: true, user: sally) }
          let!(:new_group) { new_admin_member.group }
          let!(:new_member) { create(:group_member, group: new_group, user: new_user) }

          before do
            expect(Collaborator.where(resourceable: cookbook, user: new_user, group: nil)).to_not be_empty

            find("#manage").click
            find("[rel*=add-collaborator]").click
            find(".groups", visible: false).set(new_group.id)
            click_button("Add")
            expect(page).to have_link(new_group.name)
          end

          it "adds the group user as a second collaborator" do
            expect(page).to have_link("#{new_member.user.first_name} #{new_member.user.last_name}", href: user_path(new_member.user), count: 2)
          end

          context "removing a group" do
            before do
              resource = GroupResource.where(resourceable_id: cookbook.id, group: new_group).first

              # Finds the correct "Remove Group" link associated with new_group
              find("a[href=\"#{destroy_group_collaborator_path(resourceable_type: resource.resourceable_type, resourceable_id: resource.resourceable_id, id: resource.group)}\"]").click
            end

            it "leaves the collaborator not associated with the group" do
              expect(page).to have_link("#{new_member.user.first_name} #{new_member.user.last_name}", href: user_path(new_member.user), count: 1)
            end

            it "shows a warning that the user is still a collaborator" do
              expect(page).to have_content("#{new_member.user.username} is still a collaborator")
            end
          end
        end
      end
    end

    context "transferring ownership" do
      context "when ownership is transferred to a collaborator associated with a group" do
        before do
          # Promoting Sally to admin to make testing multiple ownerships much easier
          # Since admins have full ownership/change ownership privileges
          sally.roles = ["admin"]
          sally.save!

          Feature.activate(:collaborator_groups)
          navigate_to_cookbook

          find("#manage").click
          find("[rel*=add-collaborator]").click
          find(".groups", visible: false).set(group.id)

          click_button("Add")

          within(".collaborators_avatar") do
            expect(page).to have_link("#{non_admin_group_member.user.first_name} #{non_admin_group_member.user.last_name}", href: user_path(non_admin_group_member.user))
          end

          within(".owner_avatar") do
            expect(page).to have_link("#{cookbook.owner.first_name} #{cookbook.owner.last_name}", href: user_path(cookbook.owner))
          end

          find("#manage").click
          find("[rel*=transfer_ownership]").click

          within "#transfer" do
            find(".collaborators", visible: false).set(non_admin_group_member.user.id)
          end

          click_button("Transfer")

          within(".owner_avatar") do
            expect(page).to have_link(non_admin_group_member.user.username, href: user_path(non_admin_group_member.user))
          end
        end

        it "does not remove the collaborator" do
          within(".collaborators_avatar") do
            expect(page).to have_link("#{non_admin_group_member.user.first_name} #{non_admin_group_member.user.last_name}", href: user_path(non_admin_group_member.user))
          end
        end

        context "when transferring ownership to someone else" do
          let!(:new_collaborator) { create(:cookbook_collaborator, resourceable: cookbook) }

          before do
            expect(cookbook.collaborators).to include(new_collaborator)

            within(".collaborators_avatar") do
              expect(page).to have_link("#{non_admin_group_member.user.first_name} #{non_admin_group_member.user.last_name}", href: user_path(non_admin_group_member.user), count: 1)
            end

            find("#manage").click

            find("[rel*=transfer_ownership]").click

            within "#transfer" do
              find(".collaborators", visible: false).set(new_collaborator.user.id)
            end

            click_button("Transfer")
          end

          it "does not create a new collaborator if ownership is transferred to someone else" do
            within(".collaborators_avatar") do
              expect(page).to have_link("#{non_admin_group_member.user.first_name} #{non_admin_group_member.user.last_name}", href: user_path(non_admin_group_member.user), count: 1)
            end
          end
        end
      end
    end
  end
end
