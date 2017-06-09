require 'spec_helper'

describe GroupsController do
  before do
    Feature.activate(:collaborator_groups)
  end

  describe 'GET #index' do
    let(:group1) { create(:group) }
    let(:group2) { create(:group) }

    before do
      expect(Group.all).to include(group1, group2)
    end

    it 'assigns groups' do
      get :index

      expect(assigns(:groups)).to include(group1, group2)
    end

    it 'renders the json format when requested' do
      get :index, format: :json

      expect(response).to be_success
    end

    context 'when passing a query string' do
      let(:a_group) { create(:group, name: 'a-group') }
      let(:b_group) { create(:group, name: 'b-group') }
      let(:c_group) { create(:group, name: 'c-group') }

      before do
        expect(Group.all).to include(a_group, b_group, c_group)
      end

      it 'returns groups only matching the query string' do
        get :index, params: { q: 'a', format: :json }
        group = assigns(:groups)
        expect(group.count(:all)).to eq(1)
      end
    end
  end

  describe 'GET #new' do
    it 'makes a new record' do
      get :new

      expect(assigns(:group)).to be_new_record
    end

    it 'renders the new template' do
      get :new

      expect(response).to render_template('new')
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context 'with valid input' do
      let(:group_input) do
        { name: 'My Group' }
      end

      context 'when the groups feature is not active' do
        before do
          Feature.deactivate(:collaborator_groups)
          expect(Feature.active?(:collaborator_groups)).to eq(false)
        end

        it 'does not save the new group to the database' do
          expect { post :create, params: { group: group_input } }.to change(Group, :count).by(0)
        end
      end

      context 'when the groups feature is active' do
        before do
          expect(Feature.active?(:collaborator_groups)).to eq(true)
        end

        it 'saves the new group to the database' do
          expect { post :create, params: { group: group_input } }.to change(Group, :count).by(1)
        end

        context 'after the save' do
          let(:group) { create(:group) }

          before do
            allow(Group).to receive(:new).and_return(group)
            allow(group).to receive(:save).and_return(true)
          end

          it 'shows a success message' do
            post :create, params: { group: group_input }
            expect(flash[:notice]).to include('Group successfully created!')
          end

          it 'rendirects to the group show template' do
            post :create, params: { group: group_input }
            expect(response).to redirect_to(group_path(assigns[:group]))
          end

          context 'group members' do
            it 'adds the creating user as a member' do
              post :create, params: { group: group_input }
              expect(Group.last.members).to include(user)
            end

            it 'sets the creating user as an admin member' do
              post :create, params: { group: group_input }
              expect(GroupMember.last.admin).to eq(true)
            end
          end
        end
      end

      context 'with invalid input' do
        let(:group_input) do
          { name: '' }
        end

        it 'does not save the group to the database' do
          expect { post :create, params: { group: group_input } }.to change(Group, :count).by(0)
        end

        context 'after the save' do
          let(:group) { create(:group) }

          before do
            allow(Group).to receive(:new).and_return(group)
            allow(group).to receive(:save).and_return(false)
          end

          it 'shows an error' do
            post :create, params: { group: group_input }
            expect(flash[:warning]).to include('An error has occurred')
          end

          it 'redirects to the new group template' do
            post :create, params: { group: group_input }
            expect(response).to redirect_to(new_group_path)
          end
        end
      end
    end
  end

  describe 'GET #show' do
    let(:group) { create(:group) }
    let(:user) { create(:user) }

    let!(:member) do
      create(:group_member, user: user, group: group)
    end

    let(:admin_user) { create(:user) }

    let!(:admin_member) do
      create(:admin_group_member, user: admin_user, group: group)
    end

    before do
      expect(group.members).to include(user)
    end

    it 'finds the correct group' do
      get :show, params: { id: group }
      expect(assigns(:group)).to eq(group)
    end

    context 'listing admins' do
      before do
        expect(group.members).to include(admin_user)
        expect(admin_member.admin).to eq(true)
      end

      it 'includes users who are admins' do
        get :show, params: { id: group }
        expect(assigns(:admin_members)).to include(admin_member)
      end

      it 'does not include users who are not admins' do
        get :show, params: { id: group }
        expect(assigns(:admin_members)).to_not include(user)
      end
    end

    context 'listing group members' do
      it 'includes users who are members' do
        get :show, params: { id: group }
        expect(assigns(:members)).to include(member)
      end

      it 'does not include admin members' do
        get :show, params: { id: group }
        expect(assigns(:members)).to_not include(admin_member)
      end
    end

    it 'renders the group show template' do
      get :show, params: { id: group }
      expect(response).to render_template('show')
    end
  end
end
