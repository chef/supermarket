require 'spec_helper'

describe 'GET /api/v1/cookbooks' do
  it 'returns a 200' do
    get '/api/v1/cookbooks'

    expect(response.status.to_i).to eql(200)
  end

  context 'when there are no cookbooks' do
    it 'returns an empty JSON template' do
      get '/api/v1/cookbooks'

      expect(json_body).to eql(
        'start' => 0,
        'total' => 0,
        'items' => []
      )
    end
  end

  context 'when there are cookbooks' do
    let(:sashimi) do
      {
        'cookbook_description' => 'Sashimi that will make your heart melt',
        'cookbook_maintainer' => 'Haru Maru',
        'cookbook' => 'http://www.example.com/api/v1/cookbooks/sashimi',
        'cookbook_name' => 'sashimi'
      }
    end

    let(:slow_cooking) do
      {
        'cookbook_description' => 'The best recipes for your slow cooker',
        'cookbook_maintainer' => 'Joe Doe',
        'cookbook' => 'http://www.example.com/api/v1/cookbooks/slow_cooking',
        'cookbook_name' => 'slow_cooking'
      }
    end

    before do
      create(
        :cookbook,
        description: 'The best recipes for your slow cooker',
        maintainer: 'Joe Doe',
        name: 'slow_cooking'
      )

      create(
        :cookbook,
        description: 'Sashimi that will make your heart melt',
        maintainer: 'Haru Maru',
        name: 'sashimi'
      )
    end

    it 'returns a JSON template with the cookbooks' do
      get '/api/v1/cookbooks'

      expect(json_body).to eql(
        'start' => 0,
        'total' => 2,
        'items' => [sashimi, slow_cooking]
      )
    end
  end
end
