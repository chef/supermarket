require "spec_helper"
require "webmock/rspec"

describe FetchSpdxLicenseJson do
  let(:fetch_spdx) { FetchSpdxLicenseJson.new }

  context "reads the file from assets and returns url" do
    it "returns correct license data as received from response" do
      expect(FetchSpdxLicenseJson.spdx_license_json[0]["reference"]).to eql("https://spdx.org/licenses/OLDAP-2.0.html")
      expect(FetchSpdxLicenseJson.spdx_license_json[0]["detailsUrl"]).to eql("https://spdx.org/licenses/OLDAP-2.0.json")
    end

    it "expects to return all the licenses in json file" do
      expect(FetchSpdxLicenseJson.spdx_license_json.size).to eql(475)
    end
  end

end