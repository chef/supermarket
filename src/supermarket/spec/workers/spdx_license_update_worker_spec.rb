require "spec_helper"

describe SpdxLicenseUpdateWorker, type: :worker do
  let(:cookbook) { create(:cookbook) }
  let(:json_data) do
    [
      {
        "reference": "https://spdx.org/licenses/eGenix.html",
        "isDeprecatedLicenseId": false,
        "detailsUrl": "https://spdx.org/licenses/eGenix.json",
        "referenceNumber": 0,
        "name": "eGenix.com Public License 1.1.0",
        "licenseId": "eGenix",
        "seeAlso": [
          "http://www.egenix.com/products/eGenix.com-Public-License-1.1.0.pdf",
          "https://fedoraproject.org/wiki/Licensing/eGenix.com_Public_License_1.1.0",
        ],
        "isOsiApproved": false,
      },
    ]
  end

  context "updates the spdx url for cookbook_version" do
    let(:version) { create(:cookbook_version, cookbook: cookbook, license: "eGenix") }

    before do
      allow(CookbookVersion).to receive(:find).and_return(version)
    end

    it "executes url update for given version" do
      worker = SpdxLicenseUpdateWorker.new
      Sidekiq::Testing.inline! do
        worker.perform(json_data.map { |a| HashWithIndifferentAccess.new(a) }, version.id)
      end
      expect(version.spdx_license_url).to eql("https://spdx.org/licenses/eGenix.json")
    end

    it "logs error in case of license id not found in document" do
      version.license = "Apache-2"

      worker = SpdxLicenseUpdateWorker.new
      expect do
        Sidekiq::Testing.inline! do
          worker.perform(json_data, version)
        end
      end.to raise_error(NoMethodError)
    end
  end
end
