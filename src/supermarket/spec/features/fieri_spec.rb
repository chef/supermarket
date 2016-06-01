require 'spec_helper'

# a :request spec instead of :feature, doesn't need full-on Capybara
describe 'fieri routes', type: :request do
  describe 'GET /status' do
    it 'should return a 200' do
      expect(ROLLOUT).to receive(:active?).with(:fieri).and_return(true)
      get fieri.status_path
      expect(response).to have_http_status(200)
    end
    it 'does not exist if fieri feature is disabled' do
      expect(ROLLOUT).to receive(:active?).with(:fieri).and_return(false)
      expect { get fieri.status_path }
        .to raise_error(ActionController::RoutingError)
    end
  end
end
