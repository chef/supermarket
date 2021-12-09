require "spec_helper"

describe Utils::FileFormat do
  describe "Utils::FileFormat" do
    let(:filepath) { "spec/assets/sample.txt.gz" }
    let(:mime_type) { "application/gzip" }
    it "returns gzip for gz file" do
      expect(Utils::FileFormat.get_mime_type(file_path: filepath)).to eq(mime_type)
    end
  end
end
