require 'spec_helper'

describe GroupMembersController do
  describe 'POST #make_group_admin' do
    let(:group_member) { create(:group_member) }
    let(:group) { group_member.group }
    let(:group_members) { group_member.group.group_members }
    let(:group_members_query_result) { group_member.group.group_members.where(user_id: user.id, admin: true) }

    let(:user) { create(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(user)

      allow(GroupMember).to receive(:find).and_return(group_member)
      allow(group_member).to receive(:group).and_return(group)
      allow(group).to receive(:group_members).and_return(group_members)
    end

    it 'checks whether the current user is an admin member of the group' do
      allow(group_members).to receive(:where).with(user_id: user.id, admin: true).and_return(group_members_query_result)

      expect(group_members_query_result).to receive(:present?)
      post :make_admin, params: { id: group_member }
    end

    context 'when the current user is an admin member of the group' do
      before do
        allow(controller).to receive(:current_user_admin?).and_return(true)
      end

      it 'finds the correct group member' do
        post :make_admin, params: { id: group_member }
        expect(assigns(:group_member)).to eq(group_member)
      end

      it 'makes the group member an admin' do
        expect(group_member.admin?).to eq(false)

        post :make_admin, params: { id: group_member }

        group_member.reload
        expect(group_member.admin?).to eq(true)
      end

      it 'shows a success message' do
        post :make_admin, params: { id: group_member }

        expect(flash[:notice]).to include('Member has successfully been made an admin!')
      end
    end

    context 'when the current user is not an admin member of the group' do
      before do
        allow(controller).to receive(:current_user_admin?).and_return(false)
      end

      it 'does not make the group member an admin' do
        expect(group_member.admin?).to eq(false)

        post :make_admin, params: { id: group_member }

        group_member.reload
        expect(group_member.admin?).to eq(false)
      end

      it 'shows an error message' do
        post :make_admin, params: { id: group_member }

        expect(flash[:error]).to include('You must be an admin member of the group to do that.')
      end
    end

    it 'redirects to the group#show page' do
      post :make_admin, params: { id: group_member }
      expect(response).to redirect_to(group_path(group_member.group))
    end
  end

  describe 'POST #create' do
    let(:group) { create(:group) }
    let(:user) { create(:user) }

    context 'with valid input' do
      let(:input) do
        { group_id: group.id, user_ids: user.id }
      end

      it 'saves the new group member to the database' do
        expect { post :create, params: { group_member: input } }.to change(GroupMember, :count).by(1)
      end

      context 'after the save' do
        let(:group_member) do
          create(:group_member, user: user, group: group)
        end

        before do
          allow(GroupMember).to receive(:new).and_return(group_member)
          allow(group_member).to receive(:save).and_return(true)
        end

        it 'shows a success message' do
          post :create, params: { group_member: input }
          expect(flash[:notice]).to include('Members successfully added!')
        end

        it 'redirects to the group show template' do
          post :create, params: { group_member: input }
          expect(response).to redirect_to(group_path(group))
        end

        context 'when the group is associated with a cookbook' do
          let(:cookbook) { create(:cookbook) }
          let(:group_resource) { create(:group_resource, resourceable: cookbook, group: group) }

          before do
            expect(group.group_resources).to include(group_resource)
          end

          it 'adds the new member as a collaborator to the cookbook' do
            expect(controller).to receive(:add_users_as_collaborators).with(cookbook, user.id.to_s, group.id)
            post :create, params: { group_member: input }
          end

          context 'when the group is associated with multiple cookbooks' do
            let(:cookbook2) { create(:cookbook) }
            let(:group_resource2) { create(:group_resource, resourceable: cookbook2, group: group) }

            before do
              expect(group.group_resources).to include(group_resource, group_resource2)
            end

            it 'adds the new member as a collaborator to each cookbook' do
              expect(controller).to receive(:add_users_as_collaborators).with(cookbook, user.id.to_s, group.id)
              expect(controller).to receive(:add_users_as_collaborators).with(cookbook2, user.id.to_s, group.id)
              post :create, params: { group_member: input }
            end
          end
        end
      end
    end

    context 'adding multiple users' do
      let(:user2) { create(:user) }

      let(:input) do
        { group_id: group.id, user_ids: "#{user.id},#{user2.id}" }
      end

      it 'saves both group members to the database' do
        expect { post :create, params: { group_member: input } }.to change(GroupMember, :count).by(2)
      end

      context 'when the group is associated with a cookbook' do
        let(:cookbook) { create(:cookbook) }
        let(:group_resource) { create(:group_resource, resourceable: cookbook, group: group) }

        before do
          expect(group.group_resources).to include(group_resource)
        end

        it 'adds both members as collaborators to the cookbook' do
          expect(controller).to receive(:add_users_as_collaborators).with(cookbook, user.id.to_s, group.id)
          expect(controller).to receive(:add_users_as_collaborators).with(cookbook, user2.id.to_s, group.id)
          post :create, params: { group_member: input }
        end
      end
    end

    context 'with invalid input' do
      let(:invalid_input) do
        { group_id: group.id, user_ids: nil }
      end

      it 'does not save the group to the database' do
        expect { post :create, params: { group_member: invalid_input } }.to change(GroupMember, :count).by(0)
      end

      context 'after the save' do
        let(:group_member) do
          build(:group_member, user: user, group: group)
        end

        before do
          allow(GroupMember).to receive(:new).and_return(group_member)
          allow(group_member).to receive(:save).and_return(false)
        end

        it 'shows an error' do
          post :create, params: { group_member: invalid_input }
          expect(flash[:warning]).to_not be_nil
        end
      end

      context 'when a user is already a member of the group' do
        let!(:group_member) { create(:group_member, user: user, group: group) }

        let(:input) do
          { group_id: group.id, user_ids: user.id.to_s }
        end

        before do
          expect(group.members).to include(user)
        end

        it 'shows an error' do
          post :create, params: { group_member: input }
          expect(flash[:warning]).to_not be_nil
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:group) { create(:group) }
    let(:user) { create(:user) }

    let!(:group_member) do
      create(:group_member, user: user, group: group)
    end

    it 'finds the correct group member' do
      delete :destroy, params: { id: group_member.id }
      expect(assigns(:group_member)).to eq(group_member)
    end

    context 'when the destroy is successful' do
      let(:other_user) { create(:user) }

      let!(:other_group_member) do
        create(:group_member, user: other_user, group: group)
      end

      before do
        expect(group.group_members).to include(other_group_member)
      end

      it 'removes the member from the GroupMember' do
        expect { delete :destroy, params: { id: other_group_member.id } }.to change(GroupMember, :count).by(-1)
      end

      it 'shows a success message' do
        delete :destroy, params: { id: other_group_member.id }
        expect(flash[:notice]).to include('Member successfully removed')
      end

      it 'redirects to the group index page' do
        delete :destroy, params: { id: group_member.id }
        expect(response).to redirect_to(group_path(group.id))
      end

      it 'does not remove other members' do
        delete :destroy, params: { id: group_member.id }
        expect(group.group_members).to include(other_group_member)
      end

      context 'when the group is associated with a cookbook' do
        let(:cookbook) { create(:cookbook) }

        let(:group_resource) { create(:group_resource, resourceable: cookbook, group: group) }

        let(:group_member) do
          create(:group_member, user: user, group: group)
        end

        let(:collaborator) { create(:cookbook_collaborator, resourceable: cookbook, user: user) }

        before do
          expect(group.group_resources).to include(group_resource)
          expect(cookbook.collaborators).to include(collaborator)
        end

        it 'removes the member as a collaborator on that cookbook' do
          expect(controller).to receive(:remove_collaborator).with(collaborator)
          delete :destroy, params: { id: group_member.id }
        end

        context 'when a group member is not a collaborator on the cookbook' do
          # ideally, this should not happen, but we need to handle edge cases
          before do
            collaborator.destroy
            expect(cookbook.collaborators).to_not include(collaborator)
          end

          it 'does attempt to remove the collaborator' do
            expect(controller).to_not receive(:remove_collaborator)
            delete :destroy, params: { id: group_member.id }
          end
        end
      end
    end

    context 'when the destroy is not successful' do
      before do
        allow(GroupMember).to receive(:find).and_return(group_member)
        allow(group_member).to receive(:destroy).and_return(false)
      end

      it 'shows a warning message' do
        delete :destroy, params: { id: group_member.id }
        expect(flash[:warning]).to include('An error has occurred')
      end

      it 'redirects to the group index page' do
        delete :destroy, params: { id: group_member.id }
        expect(response).to redirect_to(group_path(group.id))
      end
    end
  end
end
