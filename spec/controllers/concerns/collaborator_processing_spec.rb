require 'spec_helper'

class FakesController < ApplicationController
  include CollaboratorProcessing
end

describe FakesController do
  let!(:fanny) { create(:user, first_name: 'Fanny') }
  let!(:cookbook) { create(:cookbook, owner: fanny) }

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:user3) { create(:user) }

  let(:users) { [user1, user2, user3] }
  let(:user_ids) { "#{user1.id},#{user2.id},#{user3.id}" }

  before do
    allow(subject).to receive(:current_user) { create(:user) }
    sign_in fanny
  end

  context 'adding users' do
    context 'finding non-eligible user ids' do

      before do
        allow(Collaborator).to receive(:ineligible_collaborators_for).and_return(users)
      end

      it 'finds non-eligible users' do
        expect(Collaborator).to receive(:ineligible_collaborators_for).with(cookbook)
        subject.add_users_as_collaborators(cookbook, user_ids)
      end

      it 'maps the user ids' do
        expect(users).to receive(:map).and_return([user1.id, user2.id, user3.id])
        subject.add_users_as_collaborators(cookbook, user_ids)
      end

      it 'converts the ids to strings' do
        id_array = [user1.id, user2.id, user3.id]

        allow(users).to receive(:map).and_return(id_array)
        expect(id_array).to receive(:map).and_return(["#{user1.id}", "#{user2.id}", "#{user3.id}"])
        subject.add_users_as_collaborators(cookbook, user_ids)
      end
    end

    context 'finding users' do
      it 'finds all eligible users' do
        expect(User).to receive(:where).with(id: ["#{user1.id}", "#{user2.id}", "#{user3.id}"]).and_return(users)
        subject.add_users_as_collaborators(cookbook, user_ids)
      end

      it 'does not include non-eligible users' do
        allow(Collaborator).to receive(:ineligible_collaborators_for).and_return([user2])
        expect(User).to receive(:where).with(id: ["#{user1.id}", "#{user3.id}"]).and_return([user1, user2])
        subject.add_users_as_collaborators(cookbook, user_ids)
      end
    end

    context 'for each user' do
      let(:user) { create(:user) }
      let(:user_ids) { "#{user.id}" }
      let(:new_collaborator) { build(:cookbook_collaborator, user: user, resourceable: cookbook) }

      it 'creates a new collaborator' do
        expect(Collaborator).to receive(:new).with(user_id: user.id, resourceable: cookbook).and_return(new_collaborator)
        subject.add_users_as_collaborators(cookbook, user_ids)
      end

      it 'authorizes the collaborator' do
        expect(subject).to receive(:authorize!)
        subject.add_users_as_collaborators(cookbook, user_ids)
      end

      context 'when the current user is the owner of the resource' do
        before do
          expect(subject.current_user).to eq(fanny)
          expect(cookbook.owner).to eq(fanny)
        end

        before do
          allow(Collaborator).to receive(:new).and_return(new_collaborator)
        end

        it 'saves the new collaborator' do
          expect(new_collaborator).to receive(:save!)
          subject.add_users_as_collaborators(cookbook, user_ids)
        end

        it 'queues a mailer' do
          collaborator_mailer = double('CollaboratorMailer', delay: 'true')
          expect(CollaboratorMailer).to receive(:delay).and_return(collaborator_mailer)

          expect(collaborator_mailer).to receive(:added_email).with(new_collaborator)
          subject.add_users_as_collaborators(cookbook, user_ids)
        end
      end

      context 'when the current user is not the owner of the resource' do
        let(:hank) { create(:user, first_name: 'Hank') }
        before do
          sign_in hank
          expect(subject.current_user).to eq(hank)
          expect(cookbook.owner).to_not eq(hank)
        end

        it 'returns an error' do
          expect do
            subject.add_users_as_collaborators(cookbook, user_ids)
          end.to raise_error(Pundit::NotAuthorizedError)
        end
      end
    end
  end

  context 'removing users' do
    let!(:hank) { create(:user, first_name: 'Hank') }
    let!(:hanky) { create(:user, first_name: 'Hanky') }

    let!(:collaborator) { create(:cookbook_collaborator, resourceable: cookbook, user: hank) }

    it 'deletes a collaborator if the signed in user is the resource owner' do
      sign_in fanny

      expect do
        subject.remove_collaborator(collaborator)
      end.to change { Collaborator.count }.by(-1)

      expect(response).to be_success
    end

    it 'deletes a collaborator if the signed in user is a collaborator on this resource' do
      sign_in hank

      expect do
        subject.remove_collaborator(collaborator)
      end.to change { Collaborator.count }.by(-1)

      expect(response).to be_success
    end

    it 'fails if the signed in user is not the cookbook owner and also not a collaborator' do
      sign_in hanky

      expect do
        subject.remove_collaborator(collaborator)
      end.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
