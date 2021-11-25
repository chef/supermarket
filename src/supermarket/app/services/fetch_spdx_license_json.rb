class FetchSpdxLicenseJson

  def self.spdx_license_json
    response = JSON.parse(File.read(Rails.root.join("app/assets/data/licenses.json")))
    response["licenses"]
  rescue StandardError => e
    [:error, e]
  end

end
