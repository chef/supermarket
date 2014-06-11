require 'spec_helper'

describe CollaboratorsController do
  let!(:fanny) { create(:user) }
  let!(:hank) { create(:user, first_name: 'Hank') }
  let!(:hanky) { create(:user, first_name: 'Hanky') }
  let!(:cookbook) { create(:cookbook, owner: fanny) }
  let!(:existing_collaborator) { create(:user, collaborated_cookbooks: [cookbook]) }

  describe 'GET #index' do
    before do
      sign_in fanny
    end

    it 'returns all users except for existing collaborators and owners by default' do
      get :index, cookbook_id: cookbook, format: :json
      collaborators = assigns[:collaborators]
      expect(collaborators.size).to eql(2)
      expect(collaborators).to include(hank)
      expect(collaborators).to include(hanky)
      expect(collaborators).to_not include(fanny)
      expect(collaborators).to_not include(existing_collaborator)
      expect(response).to be_success
    end

    it 'returns only collaborators matching the query string' do
      get :index, cookbook_id: cookbook, q: 'hank', format: :json
      collaborators = assigns[:collaborators]
      expect(collaborators.count(:all)).to eql(2)
      expect(collaborators.first).to eql(hank)
      expect(response).to be_success
    end

    it 'returns existing collaborators if include_collaborators param is included' do
      get :index, cookbook_id: cookbook, format: :json, include_collaborators: true
      expect(assigns[:collaborators]).to include(existing_collaborator)
    end
  end

  describe 'destructive updates' do
    describe 'POST #create' do
      it 'creates a collaborator if the signed in user is the cookbook owner' do
        sign_in fanny

        expect do
          post :create, cookbook_id: cookbook, cookbook_collaborator: { user_id: hank.id }
        end.to change { CookbookCollaborator.count }.by(1)
        expect(response).to redirect_to(cookbook_path(cookbook))
      end

      it 'sends the collaborator an email' do
        sign_in fanny

        Sidekiq::Testing.inline! do
          expect do
            post :create, cookbook_id: cookbook, cookbook_collaborator: { user_id: hank.id }
          end.to change { ActionMailer::Base.deliveries.size }.by(1)
        end
      end

      it 'fails if the signed in user is not the cookbook owner' do
        sign_in hanky

        expect do
          post :create, cookbook_id: cookbook, cookbook_collaborator: { user_id: hank.id }
        end.to_not change { CookbookCollaborator.count }
        expect(response.status).to eql(404)
      end

      it 'does not include the cookbook owner if the cookbook owner tries to add themselves as a contributor' do
        sign_in fanny

        expect do
          post :create, cookbook_id: cookbook, cookbook_collaborator: { user_id: fanny.id }
        end.to_not change { CookbookCollaborator.count }
      end
    end

    describe 'DELETE #destroy' do
      before do
        create(:cookbook_collaborator, cookbook: cookbook, user: hank)
      end

      it 'deletes a collaborator if the signed in user is the cookbook owner' do
        sign_in fanny

        expect do
          delete :destroy, cookbook_id: cookbook, id: hank, format: :js
        end.to change { CookbookCollaborator.count }.by(-1)
        expect(response).to be_success
      end

      it 'deletes a collaborator if the signed in user is a collaborator on this cookbook' do
        sign_in hank

        expect do
          delete :destroy, cookbook_id: cookbook, id: hank, format: :js
        end.to change { CookbookCollaborator.count }.by(-1)
        expect(response).to be_success
      end

      it 'fails if the signed in user is not the cookbook owner and also not a collaborator' do
        sign_in hanky

        expect do
          delete :destroy, cookbook_id: cookbook, id: hank, format: :js
        end.to_not change { CookbookCollaborator.count }
        expect(response).to_not be_success
      end

      it 'fails if there is no collaborator for the user specified' do
        sign_in fanny

        expect do
          delete :destroy, cookbook_id: cookbook, id: hanky, format: :js
        end.to_not change { CookbookCollaborator.count }
        expect(response).to_not be_success
      end

      it 'fails if there is no collaborator for the cookbook specified' do
        redis = create(:cookbook)
        sign_in fanny

        expect do
          delete :destroy, cookbook_id: redis, id: hank, format: :js
        end.to_not change { CookbookCollaborator.count }
        expect(response).to_not be_success
      end
    end

    describe 'PUT #transfer' do
      before do
        create(:cookbook_collaborator, cookbook: cookbook, user: hank)
      end

      it 'transfers ownership to a collaborator if the signed in user is the cookbook owner' do
        sign_in fanny

        put :transfer, cookbook_id: cookbook, id: hank
        expect(response).to redirect_to(cookbook_path(cookbook))
      end

      it 'fails if the signed in user is not the cookbook owner' do
        sign_in hank

        put :transfer, cookbook_id: cookbook, id: hank
        expect(response.status).to eql(404)
      end

      it 'fails if the user is not a collaborator' do
        sign_in fanny

        put :transfer, cookbook_id: cookbook, id: hanky
        expect(response.status).to eql(404)
      end
    end
  end
end
