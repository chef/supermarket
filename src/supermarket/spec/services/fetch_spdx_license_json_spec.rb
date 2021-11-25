require "spec_helper"
require "webmock/rspec"

describe FetchSpdxLicenseJson do
  let(:fetch_spdx) { FetchSpdxLicenseJson.new }
  let(:license_json) {
    [
      {
        "reference": "https://spdx.org/licenses/APL-1.0.html",
        "isDeprecatedLicenseId": false,
        "detailsUrl": "https://spdx.org/licenses/APL-1.0.json",
        "referenceNumber": 0,
        "name": "Adaptive Public License 1.0",
        "licenseId": "APL-1.0",
        "seeAlso": [
          "https://opensource.org/licenses/APL-1.0",
        ],
        "isOsiApproved": true,
      },
      {
        "reference": "https://spdx.org/licenses/SugarCRM-1.1.3.html",
        "isDeprecatedLicenseId": false,
        "detailsUrl": "https://spdx.org/licenses/SugarCRM-1.1.3.json",
        "referenceNumber": 1,
        "name": "SugarCRM Public License v1.1.3",
        "licenseId": "SugarCRM-1.1.3",
        "seeAlso": [
          "http://www.sugarcrm.com/crm/SPL",
        ],
        "isOsiApproved": false,
      },
      {
        "reference": "https://spdx.org/licenses/Parity-6.0.0.html",
        "isDeprecatedLicenseId": false,
        "detailsUrl": "https://spdx.org/licenses/Parity-6.0.0.json",
        "referenceNumber": 2,
        "name": "The Parity Public License 6.0.0",
        "licenseId": "Parity-6.0.0",
        "seeAlso": [
          "https://paritylicense.com/versions/6.0.0.html",
        ],
        "isOsiApproved": false,
      },
    ]
  }

  before :each do
    allow(fetch_spdx).to receive(:spdx_license_json).and_return(license_json)
  end

  context "reads the file from assets and returns url" do
    it "returns correct license data as received from response" do
      expect(fetch_spdx.spdx_license_json[0][:reference]).to eql("https://spdx.org/licenses/APL-1.0.html")
      expect(fetch_spdx.spdx_license_json[0][:detailsUrl]).to eql("https://spdx.org/licenses/APL-1.0.json")
    end

    it "expects to return all the licenses in json file" do
      expect(fetch_spdx.spdx_license_json.size).to eql(3)
    end
  end

end