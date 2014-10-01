require 'spec_helper'

describe ProfileController do
  let(:user) { create(:user) }

  describe 'PATCH #update' do
    context 'user is authenticated' do
      before { sign_in user }

      it 'updates the user' do
        patch :update, user: {
          first_name: 'Bob',
          last_name:  'Loblaw'
        }
        user.reload

        expect(user.name).to eql('Bob Loblaw')
      end

      it 'redirects to the user profile' do
        patch :update, user: { first_name: 'Blob' }

        expect(response).to redirect_to(user)
      end

      it 'uses strong parameters' do
        fake_user = double(User)
        attrs = {
          'email' => 'bob@example.com',
          'first_name' => 'Bob',
          'last_name' => 'Smith',
          'company' => 'Acme',
          'twitter_username' => 'bobbo',
          'irc_nickname' => 'bobbo',
          'jira_username' => 'bobbo',
          'email_preferences' => ['new_version']
        }

        expect(fake_user).to receive(:update_attributes).with(attrs)

        allow(controller).to receive(:current_user) { fake_user }

        patch :update, user: attributes_for(:user, attrs)
      end
    end

    context 'user is not authenticated' do
      it 'redirects to the sign in page' do
        sign_out

        patch :update

        expect(response).to redirect_to(sign_in_path)
      end
    end
  end

  describe 'GET #edit' do
    context 'user is authenticated' do
      before { sign_in user }

      it 'shows the edit form' do
        get :edit

        expect(response).to render_template('edit')
      end

      it 'assigns pending requests' do
        get :edit

        expect(assigns[:pending_requests]).to_not be_nil
      end
    end

    context 'user is not authenticated' do
      it 'redirects to the sign in page' do
        sign_out

        get :edit

        expect(response).to redirect_to(sign_in_path)
      end
    end
  end

  describe 'POST #update_install_preference' do
    context 'user signed in' do
      before { sign_in user }

      it 'returns a 200 on successful update' do
        post :update_install_preference, preference: 'knife'

        expect(response.status.to_i).to eql(200)
      end

      it "updates the user's install preference" do
        post :update_install_preference, preference: 'knife'

        expect(user.install_preference).to eql('knife')
      end
    end

    context 'user not signed in' do
      it 'returns a 404' do
        post :update_install_preference, preference: 'knife'

        expect(response.status.to_i).to eql(404)
      end
    end
  end
end
