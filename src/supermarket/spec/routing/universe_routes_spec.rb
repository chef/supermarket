require "spec_helper"

describe "universe routes" do
  context "API" do
    context "universe#index" do
      it "can route using /api/v1/universe path" do
        expect(get: "/api/v1/universe", format: :json).to route_to(controller: "api/v1/universe", action: "index", format: :json)
      end

      it "routes GET /universe to UniverseController#index" do
        expect(get: "/universe").to route_to(format: :json, controller: "api/v1/universe", action: "index")
      end
    end
  end
end