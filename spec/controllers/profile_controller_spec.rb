require 'spec_helper'

describe ProfileController do
  let(:user) { create(:user, password: 'password', password_confirmation: 'password') }

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
        fake_user = stub_model(User)

        expect(fake_user).to receive(:update_attributes).with({
          'email' => 'bob@example.com',
          'first_name' => 'Bob',
          'last_name' => 'Smith',
          'company' => 'Acme',
          'irc_nickname' => 'bobbo',
          'jira_username' => 'bobbo'
        })

        controller.stub(:current_user) { fake_user }

        patch :update, user: {
          'email' => 'bob@example.com',
          'first_name' => 'Bob',
          'last_name' => 'Smith',
          'company' => 'Acme',
          'irc_nickname' => 'bobbo',
          'jira_username' => 'bobbo'
        }
      end
    end

    context 'user is not authenticated' do
      it 'redirects to the sign in page' do
        sign_out user

        patch :update

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH #change_password' do
    context 'user is authenticated' do
      before do
        sign_in user

        patch :change_password, user: {
          current_password: 'password',
          password: 'winter123',
          password_confirmation:'winter123'
        }
      end

      it 'changes the users password' do
        old_encrypted_password = user.encrypted_password
        user.reload

        expect(user.encrypted_password).to_not eql(old_encrypted_password)
      end

      it 'redirects to the user profile' do
        expect(response).to redirect_to(user)
      end

      it 'uses strong parameters' do
        fake_user = stub_model(User)

        expect(fake_user).to receive(:update_with_password).with({
          'current_password' => 'password',
          'password' => 'winter123',
          'password_confirmation' => 'winter123'
        })

        controller.stub(:current_user) { fake_user }

        patch :change_password, user: attributes_for(:user, {
          'current_password' => 'password',
          'password' => 'winter123',
          'password_confirmation' => 'winter123'
        })
      end
    end

    context 'user is not authenticated' do
      it 'redirects to the sign in page' do
        sign_out user

        patch :update

        expect(response).to redirect_to(new_user_session_path)
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
    end

    context 'user is not authenticated' do
      it 'redirects to the sign in page' do
        sign_out user

        get :edit

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
