require 'spec_helper'

describe 'GET /api/v1/cookbooks/:cookbook/contingent' do
  context 'when the cookbook exists' do
    let(:apt) { create(:cookbook, name: 'apt') }
    let(:nginx) { create(:cookbook, name: 'nginx') }
    let(:apache) { create(:cookbook, name: 'apache') }

    before do
      create(:cookbook_dependency, cookbook: apt, cookbook_version: nginx.latest_cookbook_version)
      create(:cookbook_dependency, cookbook: apt, cookbook_version: apache.latest_cookbook_version)
      get '/api/v1/cookbooks/apt/contingent'
    end

    it 'returns a 200' do
      expect(response.status.to_i).to eql(200)
    end

    it 'returns the cookbooks' do
      contingents = json_body['contingents']
      expect(contingents.size).to eql(2)
      expect(contingents.first['name']).to eql('apache')
      expect(contingents.last['name']).to eql('nginx')
    end
  end

  context 'when the cookbook does not exist' do
    it 'returns a 404' do
      get '/api/v1/cookbooks/mamimi'

      expect(response.status.to_i).to eql(404)
    end

    it 'returns a 404 message' do
      get '/api/v1/cookbooks/mamimi'

      expect(json_body).to eql(error_404)
    end
  end
end
