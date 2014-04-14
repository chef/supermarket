require 'spec_helper'

describe CollaboratorsController do
  let!(:fanny) { create(:user) }
  let!(:hank) { create(:user, first_name: 'hank') }
  let!(:hanky) { create(:user, first_name: 'hanky') }
  let!(:cookbook) { create(:cookbook, owner: fanny) }

  before do
    create(:icla_signature, user: fanny)
    create(:icla_signature, user: hank)
  end

  describe 'GET #index' do
    it 'returns all collaborators that have an icla by default' do
      get :index, format: :json
      c = assigns[:collaborators]
      expect(c.size).to eql(2)
      expect(c).to include(fanny)
      expect(c).to include(hank)
      expect(response).to be_success
    end

    it 'returns only collaborators matching the query string that have an icla' do
      get :index, q: 'hank', format: :json
      c = assigns[:collaborators]
      expect(c.size).to eql(1)
      expect(c.first).to eql(hank)
      expect(response).to be_success
    end
  end

  describe 'destructive updates' do
    describe 'POST #create' do
      it 'creates a collaborator if the signed in user is the cookbook owner' do
        sign_in fanny

        expect do
          post :create, cookbook_id: cookbook.to_param, cookbook_collaborator: { user_id: hank.to_param }
        end.to change { CookbookCollaborator.count }.by(1)
        expect(response).to redirect_to(cookbook_path(cookbook))
      end

      it 'fails if the signed in user is not the cookbook owner' do
        sign_in hanky

        expect do
          post :create, cookbook_id: cookbook.to_param, cookbook_collaborator: { user_id: hank.to_param }
        end.to_not change { CookbookCollaborator.count }
        expect(response).to redirect_to(cookbook_path(cookbook))
      end
    end

    describe 'DELETE #destroy' do
      before do
        CookbookCollaborator.create! cookbook: cookbook, user: hank
      end

      it 'deletes a collaborator if the signed in user is the cookbook owner' do
        sign_in fanny

        expect do
          delete :destroy, cookbook_id: cookbook.to_param, id: hank.to_param, format: :js
        end.to change { CookbookCollaborator.count }.by(-1)
        expect(response).to be_success
      end

      it 'deletes a collaborator if the signed in user is a collaborator on this cookbook' do
        sign_in hank

        expect do
          delete :destroy, cookbook_id: cookbook.to_param, id: hank.to_param, format: :js
        end.to change { CookbookCollaborator.count }.by(-1)
        expect(response).to be_success
      end

      it 'fails if the signed in user is not the cookbook owner and also not a collaborator' do
        sign_in hanky

        expect do
          delete :destroy, cookbook_id: cookbook.to_param, id: hank.to_param, format: :js
        end.to_not change { CookbookCollaborator.count }
        expect(response).to_not be_success
      end

      it 'fails if there is no collaborator for the user specified' do
        sign_in fanny

        expect do
          delete :destroy, cookbook_id: cookbook.to_param, id: hanky.to_param, format: :js
        end.to_not change { CookbookCollaborator.count }
        expect(response).to_not be_success
      end

      it 'fails if there is no collaborator for the cookbook specified' do
        redis = create(:cookbook)
        sign_in fanny

        expect do
          delete :destroy, cookbook_id: redis.to_param, id: hank.to_param, format: :js
        end.to_not change { CookbookCollaborator.count }
        expect(response).to_not be_success
      end
    end
  end
end
