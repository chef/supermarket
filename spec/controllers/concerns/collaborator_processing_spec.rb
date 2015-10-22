require 'spec_helper'

class FakesController < ApplicationController
  include CollaboratorProcessing
end

describe FakesController do
  let(:cookbook) { create(:cookbook) }
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:user3) { create(:user) }

  let(:users) {[user1, user2, user3]}
  let(:user_ids) { "#{user1.id},#{user2.id},#{user3.id}" }

  before do
    allow(subject).to receive(:current_user) { create(:user) }
  end

  context 'finding the resource' do
    context 'when the resource is a cookbook' do
      it 'finds the correct cookbook' do
        expect(Cookbook).to receive(:find).with(cookbook.id).and_return(cookbook)
        subject.add_users_as_collaborators('Cookbook', cookbook.id, user_ids)
      end
    end

    context 'when the resource is a tool' do
      let(:tool) { create(:tool) }

      it 'finds the correct tool' do
        expect(Tool).to receive(:find).with(tool.id).and_return(tool)
        subject.add_users_as_collaborators('Tool', tool.id, user_ids)
      end
    end
  end

  context 'adding users' do
    context 'finding non-eligible user ids' do

      before do
        allow(Collaborator).to receive(:ineligible_collaborators_for).and_return(users)
      end

      it 'finds non-eligible users' do
        expect(Collaborator).to receive(:ineligible_collaborators_for).with(cookbook)
        subject.add_users_as_collaborators('Cookbook', cookbook.id, user_ids)
      end

      it 'maps the user ids' do
        expect(users).to receive(:map).and_return([user1.id, user2.id, user3.id])
        subject.add_users_as_collaborators('Cookbook', cookbook.id, user_ids)
      end

      it 'converts the ids to strings' do
        id_array = [user1.id,user2.id,user3.id]

        allow(users).to receive(:map).and_return(id_array)
        expect(id_array).to receive(:map).and_return(user_ids)
        subject.add_users_as_collaborators('Cookbook', cookbook.id, user_ids)
      end
    end

    context 'finding users' do
      it 'finds all eligible users' do
        expect(User).to receive(:where).with(id: ["#{user1.id}","#{user2.id}","#{user3.id}"]).and_return(users)
        subject.add_users_as_collaborators('Cookbook', cookbook.id, user_ids)
      end

      it 'does not include non-eligible users' do
        allow(Collaborator).to receive(:ineligible_collaborators_for).and_return([user2])
        expect(User).to receive(:where).with(id: ["#{user1.id}","#{user3.id}"]).and_return([user1,user2])
        subject.add_users_as_collaborators('Cookbook', cookbook.id, user_ids)
      end
    end
  end
end
