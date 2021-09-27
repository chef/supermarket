require "spec_helper"

describe CollaboratorsController do
  let!(:fanny) { create(:user, first_name: "Fanny") }
  let!(:hank) { create(:user, first_name: "Hank") }
  let!(:hanky) { create(:user, first_name: "Hanky") }
  let!(:cookbook) { create(:cookbook, owner: fanny) }
  let!(:existing_collaborator) { create(:user, collaborated_cookbooks: [cookbook]) }

  describe "GET #index" do
    before do
      sign_in fanny
    end

    it "returns only collaborators matching the query string" do
      get :index, params: { cookbook_id: cookbook, q: "hank", format: :json }
      collaborators = assigns[:collaborators]
      expect(collaborators.count(:all)).to eql(2)
      expect(collaborators.first).to eql(hank)
      expect(response).to be_successful
    end

    it "doesn't return users that are ineligible" do
      get :index, params: { cookbook_id: cookbook, format: :json, ineligible_user_ids: [fanny.id, existing_collaborator.id] }
      collaborators = assigns[:collaborators]
      # expect(collaborators.size).to eql(2)
      expect(collaborators).to include(hank)
      expect(collaborators).to include(hanky)
      expect(collaborators).to_not include(fanny)
      expect(collaborators).to_not include(existing_collaborator)
      expect(response).to be_successful
    end
  end

  describe "destructive updates" do
    describe "POST #create" do
      it "creates a collaborator if the signed in user is the resource owner" do
        sign_in fanny

        expect do
          post :create, params: { collaborator: { user_ids: hank.id, resourceable_type: "Cookbook", resourceable_id: cookbook.id } }
        end.to change { Collaborator.count }.by(1)
        expect(response).to redirect_to(cookbook)
      end

      it "adds the user as a collaborator" do
        sign_in fanny

        expect(controller).to receive(:add_users_as_collaborators).with(cookbook, hank.id.to_s)
        post :create, params: { collaborator: { user_ids: hank.id, resourceable_type: "Cookbook", resourceable_id: cookbook.id } }
      end

      it "does not include the resource owner if the resource owner tries to add themselves as a contributor" do
        sign_in fanny

        expect do
          post :create, params: { collaborator: { user_ids: fanny.id, resourceable_type: "Cookbook", resourceable_id: cookbook.id } }
        end.to change { Collaborator.count }.by(0)
      end

      it "returns a 404 if an unknown resource type is in the params" do
        sign_in fanny

        post :create, params: { collaborator: { user_ids: hank.id, resourceable_type: "Butter", resourceable_id: cookbook.id } }

        expect(response.status).to eql(404)
      end

      it "re-evaluates collaborator rating" do
        sign_in fanny
        expect do
          post :create, params: { collaborator: { user_ids: hank.id, resourceable_type: "Cookbook", resourceable_id: cookbook.id } }
        end.to change(FieriNotifyWorker.jobs, :size).by(1)
      end

      context "when adding a group of collaborators" do
        let(:group1) { create(:group) }
        let(:group2) { create(:group) }

        it "adds collaborators for all groups" do
          sign_in fanny
          expect(controller).to receive(:add_group_members_as_collaborators).with(cookbook, "#{group1.id}, #{group2.id}")

          post :create, params: { collaborator: { group_ids: "#{group1.id}, #{group2.id}", resourceable_type: "Cookbook", resourceable_id: cookbook.id } }
        end
      end
    end

    describe "DELETE #destroy" do
      let!(:collaborator) { create(:cookbook_collaborator, resourceable: cookbook, user: hank) }

      it "calls the remove collaborator method" do
        sign_in fanny
        expect(controller).to receive(:remove_collaborator).with(collaborator)
        delete :destroy, params: { id: collaborator, format: :js }
      end

      it "re-evaluates collaborator rating" do
        sign_in fanny
        expect do
          delete :destroy, params: { id: collaborator, format: :js }
        end.to change(FieriNotifyWorker.jobs, :size).by(1)
      end

      context "removing a group of collaborators" do
        let!(:group_member1) { create(:group_member) }
        let!(:group) { group_member1.group }
        let!(:group_member2) { create(:group_member, group: group) }

        let!(:collaborator1) { create(:cookbook_collaborator, group: group, user: group_member1.user, resourceable: cookbook) }
        let!(:collaborator2) { create(:cookbook_collaborator, group: group, user: group_member2.user, resourceable: cookbook) }

        let(:group_resource) { create(:group_resource, resourceable: cookbook, group: group) }
        let(:group_resources) { GroupResource.where(group: group, resourceable: cookbook) }

        let(:collaborators) { Collaborator.where(group: group, resourceable: cookbook) }

        before do
          sign_in fanny
        end

        it "finds the correct group" do
          expect(Group).to receive(:find).with(group.id.to_s).and_return(group)
          delete :destroy_group, params: { id: group, resourceable_id: cookbook.id, resourceable_type: "Cookbook" }
        end

        it "finds the correct resource" do
          expect(Cookbook).to receive(:find).with(cookbook.id.to_s).and_return(cookbook)
          delete :destroy_group, params: { id: group, resourceable_id: cookbook.id, resourceable_type: "Cookbook" }
        end

        it "finds the correct group resource" do
          expect(GroupResource).to receive(:where).with(group: group, resourceable: cookbook).and_return(group_resources)
          delete :destroy_group, params: { id: group, resourceable_id: cookbook.id, resourceable_type: "Cookbook" }
        end

        it "removes the group_resource entry" do
          allow(GroupResource).to receive(:where).and_return(group_resources)

          group_resources.each do |group_resource|
            expect(group_resource).to receive(:destroy)
          end

          delete :destroy_group, params: { id: group, resourceable_id: cookbook.id, resourceable_type: "Cookbook" }
        end

        it "re-evaluates collaborator rating" do
          sign_in fanny
          expect do
            delete :destroy_group, params: { id: group, resourceable_id: cookbook.id, resourceable_type: "Cookbook" }
          end.to change(FieriNotifyWorker.jobs, :size).by(2)
        end

        it "removes all collaborators associated with that group" do
          allow(Collaborator).to receive(:where).and_return(collaborators)
          expect(controller).to receive(:remove_group_collaborators).with(Collaborator.where(group: group, resourceable: cookbook))
          delete :destroy_group, params: { id: group, resourceable_id: cookbook.id, resourceable_type: "Cookbook" }
        end

        it "redirects back to the resource page" do
          delete :destroy_group, params: { id: group, resourceable_id: cookbook.id, resourceable_type: "Cookbook" }
          expect(response).to redirect_to(cookbook_path(cookbook))
        end

        it "shows a success message" do
          delete :destroy_group, params: { id: group, resourceable_id: cookbook.id, resourceable_type: "Cookbook" }
          expect(flash[:notice]).to include("#{group.name} successfully removed")
        end

        context "removing a collaborator who is also a member of a second group associated with the resource" do
          let!(:group_2) { create(:group) }
          let!(:group_2_member) { create(:group_member, group: group_2, user: group_member1.user) }
          let!(:group_resource) { create(:group_resource, resourceable: cookbook, group: group_2) }
          let!(:group_2_collaborator) { create(:cookbook_collaborator, resourceable: cookbook, user: group_member1.user, group_id: group_2.id) }

          before do
            expect(group_2.group_members).to include(group_2_member)
            expect(group_2_member.user).to eq(group_member1.user)
          end

          it "does not remove the collaborator record for the second group" do
            expect(cookbook.collaborator_users).to include(group_2_member.user)
            delete :destroy_group, params: { id: group, resourceable_id: cookbook.id, resourceable_type: "Cookbook" }
            expect(cookbook.collaborator_users).to include(group_2_member.user)
          end

          it "finds all users associated with the collaborators" do
            allow(Collaborator).to receive(:where).and_return(collaborators)
            expect(collaborators).to receive(:map).and_return([group_member1.user])
            delete :destroy_group, params: { id: group, resourceable_id: cookbook.id, resourceable_type: "Cookbook" }
          end

          it "shows a message to the user" do
            delete :destroy_group, params: { id: group, resourceable_id: cookbook.id, resourceable_type: "Cookbook" }
            expect(flash[:notice]).to include(
              "#{group_member1.user.username} is still a collaborator associated with #{group_2.name}"
            )
          end
        end
      end
    end

    describe "PUT #transfer" do
      let!(:collaborator) { create(:cookbook_collaborator, resourceable: cookbook, user: hank) }

      it "transfers ownership to a collaborator if the signed in user is the resource owner" do
        sign_in fanny

        put :transfer, params: { id: collaborator }
        expect(cookbook.reload.owner).to eql(collaborator.user)
        expect(response).to redirect_to(cookbook_path(cookbook))
      end

      it "fails if the signed in user is not the resource owner" do
        sign_in hank

        put :transfer, params: { id: collaborator }
        expect(response.status).to eql(404)
      end
    end
  end
end
