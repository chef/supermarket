require 'spec_helper'

describe 'contributor request routes' do
  let(:request_route) { { post: '/ccla-signatures/1/contributor_requests' } }
  let(:accept_route) { { get: '/ccla-signatures/1/contributor_requests/1/accept' } }
  let(:decline_route) { { get: '/ccla-signatures/1/contributor_requests/1/decline' } }

  context "when ENV['JOIN_CCLA_ENABLED'] is present" do
    it 'has a route to create requests' do
      route = {
        controller: 'contributor_requests',
        action: 'create',
        ccla_signature_id: '1'
      }

      expect(request_route).to route_to(route)
    end

    it 'has a route to accept requests' do
      route = {
        controller: 'contributor_requests',
        action: 'accept',
        ccla_signature_id: '1',
        id: '1'
      }

      expect(accept_route).to route_to(route)
    end

    it 'has a route to decline requests' do
      route = {
        controller: 'contributor_requests',
        action: 'decline',
        ccla_signature_id: '1',
        id: '1'
      }

      expect(decline_route).to route_to(route)
    end
  end

  context "when ENV['JOIN_CCLA_ENABLED'] is not present" do
    around do |example|
      with_env('JOIN_CCLA_ENABLED' => nil) do
        example.run
      end
    end

    it 'has no route to create requests' do
      expect(request_route).to_not be_routable
    end

    it 'has no route to accept requests' do
      expect(accept_route).to_not be_routable
    end

    it 'has no route to decline requests' do
      expect(decline_route).to_not be_routable
    end
  end
end
