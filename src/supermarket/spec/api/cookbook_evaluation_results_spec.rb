require "spec_helper"

describe "POST /api/v1/cookbook_evalution_results" do
  let(:cookbook) { create(:cookbook) }
  let(:cookbook_version) { create(:cookbook_version, cookbook: cookbook) }

  context "with the correct spelling" do
    it "returns a 200" do
      post "/api/v1/cookbook-versions/cookstyle_evaluation",
           params: { cookbook_name: cookbook.name,
                     cookbook_version: cookbook_version.version,
                     cookstyle_failure: false,
                     cookstyle_feedback: nil,
                     fieri_key: "YOUR_FIERI_KEY" }

      expect(response.status.to_i).to eql(200)
    end
  end
end
