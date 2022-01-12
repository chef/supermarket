require "spec_helper"

describe QualityMetric do
  it { should have_many(:metric_results) }

  describe "validations" do
    it "enforces unique names" do
      create(:cookstyle_metric)
      dup_qm = build(:cookstyle_metric)
      expect(dup_qm).to_not be_valid
    end
  end

  describe "#cookstyle metric" do
    let!(:cookstyle_metric) do
      create(:cookstyle_metric)
    end

    it "finds the cookstyle metric" do
      expect(QualityMetric.cookstyle_metric).to eq(cookstyle_metric)
    end
  end

  describe "#collaborators_num_metric" do
    let!(:collaborator_metric) do
      create(:collaborator_num_metric)
    end

    it "finds the collaborators num metric" do
      expect(QualityMetric.collaborator_num_metric).to eq(collaborator_metric)
    end
  end

  describe "#license_metric" do
    let!(:license_metric) do
      create(:license_metric)
    end

    it "finds the license metric" do
      expect(QualityMetric.license_metric).to eq(license_metric)
    end
  end

  describe "#supported_platforms_metric" do
    let!(:supported_platforms_metric) do
      create(:supported_platforms_metric)
    end

    it "finds the supported platforms metric" do
      expect(QualityMetric.supported_platforms_metric).to eq(supported_platforms_metric)
    end
  end

  describe "#contributing_file_metric" do
    let!(:contributing_file_metric) do
      create(:contributing_file_metric)
    end

    it "finds the contributing file metric" do
      expect(QualityMetric.contributing_file_metric).to eq(contributing_file_metric)
    end
  end

  describe "#testing_file_metric" do
    let!(:testing_file_metric) do
      create(:testing_file_metric)
    end

    it "finds the testing file metric" do
      expect(QualityMetric.testing_file_metric).to eq(testing_file_metric)
    end
  end

  describe "#version_tag_metric" do
    let!(:version_tag_metric) do
      create(:version_tag_metric)
    end

    it "finds the version tag metric" do
      expect(QualityMetric.version_tag_metric).to eq(version_tag_metric)
    end
  end

  describe "#no_binaries_metric" do
    let!(:no_binaries_metric) do
      create(:no_binaries_metric)
    end

    it "finds the testing file metric" do
      expect(QualityMetric.no_binaries_metric).to eq(no_binaries_metric)
    end
  end
end
