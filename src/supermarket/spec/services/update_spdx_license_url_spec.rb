require "spec_helper"

describe UpdateSpdxLicenseUrl do
  context "on the supplied version of a single cookbook" do
    let(:cookbook) { create :cookbook }
    let(:cookbook_version) { cookbook.latest_cookbook_version }

    it "returns a message about successful scheduling" do
      allow(SpdxLicenseUpdateWorker).to receive(:perform_async)
      success_message = I18n.t("spdx_license.scheduled.single", name: cookbook.name, version: cookbook_version.id)

      expect(UpdateSpdxLicenseUrl.on_version(cookbook.name, cookbook_version.version))
        .to eql([:ok, success_message])
    end

    it "returns an error when a cookbook is not found with a given name" do
      expect(SpdxLicenseUpdateWorker).not_to receive(:perform_async)
      error_message = I18n.t("cookbook.not_found", name: "nope")

      expect(UpdateSpdxLicenseUrl.on_version("nope", cookbook_version.version))
        .to eql([:error, error_message])
    end

    it "returns an error when a cookbook is not found with a given version" do
      create(:cookbook, name: "got-no-nines")
      expect(SpdxLicenseUpdateWorker).not_to receive(:perform_async)
      error_message = I18n.t("cookbook.version_not_found", name: "got-no-nines", version: "9.9.9")

      expect(UpdateSpdxLicenseUrl.on_version("got-no-nines", "9.9.9"))
        .to eql([:error, error_message])
    end
  end

  context "on all the latest cookbook versions" do
    before :each do
      13.times do
        create(:cookbook)
      end
    end

    it "schedules to run the functionality" do
      expect(SpdxLicenseUpdateWorker).to receive(:perform_async).exactly(13).times
      UpdateSpdxLicenseUrl.all_latest_cookbook_versions
    end

    it "returns a message about successful scheduling" do
      allow(SpdxLicenseUpdateWorker).to receive(:perform_async)
      success_message = I18n.t("spdx_license.scheduled.multiple", count: 13)

      expect(UpdateSpdxLicenseUrl.all_latest_cookbook_versions)
        .to eq([:ok, success_message])
    end
  end
end
