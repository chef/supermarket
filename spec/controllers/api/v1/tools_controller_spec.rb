require 'spec_helper'

describe Api::V1::ToolsController do
  describe '#show' do
    context 'when a tool exists' do
      let!(:berkshelf_tool) { create(:tool, name: 'berkshelf') }

      it 'responds with a 200' do
        get :show, tool: berkshelf_tool.name, format: :json

        expect(response.status.to_i).to eql(200)
      end

      it 'sends the tool to the view' do
        get :show, tool: berkshelf_tool.name, format: :json

        expect(assigns[:tool]).to eql(berkshelf_tool)
      end
    end

    context 'when a tool does not exist' do
      it 'responds with a 404' do
        get :show, tool: 'trololol', format: :json

        expect(response.status.to_i).to eql(404)
      end
    end
  end
end
