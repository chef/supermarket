require 'spec_helper'

describe CollaboratorsController do
  let!(:fanny) { create(:user) }
  let!(:cookbook) { create(:cookbook, owner: fanny) }

  describe 'GET #index' do
    it 'returns all collaborators by default' do
      get :index, format: :json
      c = assigns[:collaborators]
      expect(c.size).to eql(1)
      expect(c.first).to eql(fanny)
      expect(response).to be_success
    end

    it 'returns only collaborators matching the query string' do
      jimmy = create(:user, first_name: 'Jimmy', last_name: 'Hoffa')

      get :index, q: 'Jimmy', format: :json
      c = assigns[:collaborators]
      expect(c.size).to eql(1)
      expect(c.first).to eql(jimmy)
      expect(response).to be_success
    end
  end

  describe 'destructive updates' do
    let!(:sally) { create(:user) }
    let!(:hank) { create(:user) }

    describe 'POST #create' do
      it 'creates a collaborator if the signed in user is the cookbook owner' do
        sign_in fanny

        expect do
          post :create, cookbook_id: cookbook.to_param, user_id: hank.to_param, format: :json
        end.to change { CookbookCollaborator.count }.by(1)
        expect(response).to be_success
      end

      it 'fails if the signed in user is not the cookbook owner' do
        sign_in sally

        expect do
          post :create, cookbook_id: cookbook.to_param, user_id: hank.to_param, format: :json
        end.to_not change { CookbookCollaborator.count }
        expect(response).to_not be_success
      end
    end

    describe 'DELETE #destroy' do
      before do
        CookbookCollaborator.create! cookbook: cookbook, user: hank
      end

      it 'deletes a collaborator if the signed in user is the cookbook owner' do
        sign_in fanny

        expect do
          delete :destroy, cookbook_id: cookbook.to_param, user_id: hank.to_param, format: :json
        end.to change { CookbookCollaborator.count }.by(-1)
        expect(response).to be_success
      end

      it 'deletes a collaborator if the signed in user is a collaborator on this cookbook' do
        sign_in hank

        expect do
          delete :destroy, cookbook_id: cookbook.to_param, user_id: hank.to_param, format: :json
        end.to change { CookbookCollaborator.count }.by(-1)
        expect(response).to be_success
      end

      it 'fails if the signed in user is not the cookbook owner and also not a collaborator' do
        sign_in sally

        expect do
          delete :destroy, cookbook_id: cookbook.to_param, user_id: hank.to_param, format: :json
        end.to_not change { CookbookCollaborator.count }
        expect(response).to_not be_success
      end

      it 'fails if there is no collaborator for the user specified' do
        sign_in fanny

        expect do
          delete :destroy, cookbook_id: cookbook.to_param, user_id: sally.to_param, format: :json
        end.to_not change { CookbookCollaborator.count }
        expect(response).to_not be_success
      end

      it 'fails if there is no collaborator for the cookbook specified' do
        redis = create(:cookbook)
        sign_in fanny

        expect do
          delete :destroy, cookbook_id: redis.to_param, user_id: hank.to_param, format: :json
        end.to_not change { CookbookCollaborator.count }
        expect(response).to_not be_success
      end
    end
  end
end
