class FetchSpdxLicenseJson

  def self.spdx_license_json
    response = JSON.parse(File.read(File.join(Rails.root,'/app/assets/data/licenses.json')))
    response["licenses"]
  rescue StandardError => e
    [:error, e]
  end

end
