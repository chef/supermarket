require 'spec_helper'

describe Api::V1::ToolsController do
  describe '#index' do
    let!(:metal) do
      create(:tool, name: 'metal')
    end

    let!(:berkshelf) do
      create(:tool, name: 'berkshelf')
    end

    it 'responds with a 200' do
      get :index, format: :json

      expect(response.status.to_i).to eql(200)
    end

    it 'sends the tools to view' do
      get :index, format: :json

      expect(assigns[:tools]).to be_present
    end

    it 'sends the total tools count to view' do
      get :index, format: :json

      expect(assigns[:total]).to be_present
    end

    it 'sends start to view' do
      get :index, start: 4, format: :json

      expect(assigns[:start]).to eql(4)
    end

    it 'sends items to view' do
      get :index, format: :json

      expect(assigns[:items]).to be_present
    end

    it 'sends order to view' do
      get :index, format: :json

      expect(assigns[:order]).to be_present
    end

    it 'orders the tools by their name by default' do
      get :index, format: :json

      tool_names = assigns[:tools].map(&:name)

      expect(tool_names).to eql(%W(berkshelf metal))
    end

    it 'allows ordering by recently added' do
      get :index, order: :recently_added, format: :json
      tools = assigns[:tools]
      expect(tools.first).to eql(berkshelf)
      expect(tools.last).to eql(metal)
    end

    it 'uses the start param to offset the tools sent to the view' do
      get :index, start: 1, format: :json

      tool_names = assigns[:tools].map(&:name)

      expect(tool_names).to eql(['metal'])
    end

    it 'uses the items param to limit the tools sent to the view' do
      get :index, items: 1, format: :json

      tool_names = assigns[:tools].map(&:name)

      expect(tool_names).to eql(['berkshelf'])
    end

    it 'handles the start and items param' do
      get :index, items: 1, start: 1, format: :json

      tools_names = assigns[:tools].map(&:name)

      expect(tools_names).to eql(['metal'])
    end

    it 'defaults the items param to 10' do
      get :index, format: :json

      expect(assigns[:items]).to eql(10)
    end

    it 'defaults the start param to 0' do
      get :index, format: :json

      expect(assigns[:start]).to eql(0)
    end

    it 'limits the number of items to 100' do
      get :index, items: 101, format: :json

      expect(assigns[:items]).to eql(100)
    end

    it 'returns a 400 if start is negative' do
      get :index, start: -1, format: :json

      expect(response.status).to eql(400)
    end

    it 'returns a 400 if items is negative' do
      get :index, items: -1, format: :json

      expect(response.status).to eql(400)
    end
  end

  describe '#show' do
    context 'when a tool exists' do
      let!(:berkshelf_tool) { create(:tool, name: 'berkshelf') }

      it 'responds with a 200' do
        get :show, tool: berkshelf_tool.slug, format: :json

        expect(response.status.to_i).to eql(200)
      end

      it 'sends the tool to the view' do
        get :show, tool: berkshelf_tool.slug, format: :json

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
