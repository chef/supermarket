require 'spec_helper'

describe Api::V1::UniverseController do
  describe '#index' do
    it 'tracks the hits in SegmentIO' do
      get :index, format: :json

      expect(SegmentIO.last_event).to eql(
        name: 'universe_api_visit',
        user_id: 'anonymous',
        properties: {}
      )
    end
  end
end
