require 'spec_helper'

class FakesController < ApplicationController
  include CollaboratorProcessing
end

describe FakesController do
  let(:cookbook) { create(:cookbook) }

  context 'finding the resource' do
    context 'when the resource is a cookbook' do
      it 'finds the correct cookbook' do
        expect(Cookbook).to receive(:find).with(cookbook.id).and_return(cookbook)
        subject.add_users_as_collaborators('Cookbook', cookbook.id)
      end
    end

    context 'when the resource is a tool' do
      let(:tool) { create(:tool) }

      it 'finds the correct tool' do
        expect(Tool).to receive(:find).with(tool.id).and_return(tool)
        subject.add_users_as_collaborators('Tool', tool.id)
      end
    end
  end

  context 'finding users' do
    context 'finding non-eligible user ids' do
#      it 'finds non-eligible users' do
#        expect(Collaborator).to receive(:ineligible_collaborators_for).with(cookbook)
#        subject.add_users_as_collaborators
#      end
    end
  end
end
