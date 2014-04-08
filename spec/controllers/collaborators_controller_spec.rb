require 'spec_helper'

describe CollaboratorsController do
  let!(:user) { create(:user) }
  let!(:cookbook) { create(:cookbook) }

  describe 'GET #index' do
    it 'returns all collaborators by default' do
      get :index, format: :json
      c = assigns[:collaborators]
      expect(c.size).to eql(1)
      expect(c.first).to eql(user)
      expect(response).to be_success
    end

    it 'returns only collaborators matching the query string' do
      jimmy = create(:user, first_name: 'Jimmy', last_name: 'Hoffa')
      expect(User.count).to eql(2)

      get :index, q: 'Jimmy', format: :json
      c = assigns[:collaborators]
      expect(c.size).to eql(1)
      expect(c.first).to eql(jimmy)
      expect(response).to be_success
    end
  end
end
