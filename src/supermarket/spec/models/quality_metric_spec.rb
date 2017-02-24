require 'spec_helper'

describe QualityMetric do
  it { should have_many(:metric_results) }

  describe 'validations' do
    it 'enforces unique names' do
      create(:foodcritic_metric)
      dup_qm = build(:foodcritic_metric)
      expect(dup_qm).to_not be_valid
    end
  end

  describe '#foodcritic metric' do
    let!(:foodcritic_metric) do
      create(:foodcritic_metric)
    end

    it 'finds the foodcritic metric' do
      expect(QualityMetric.foodcritic_metric).to eq(foodcritic_metric)
    end
  end

  describe '#collaborators_num_metric' do
    let!(:collaborator_metric) do
      create(:collaborator_num_metric)
    end

    it 'finds the collaborators num metric' do
      expect(QualityMetric.collaborator_num_metric).to eq(collaborator_metric)
    end
  end

  describe '#publish_metric' do
    let!(:publish_metric) do
      create(:publish_metric)
    end

    it 'finds the publish metric' do
      expect(QualityMetric.publish_metric).to eq(publish_metric)
    end
  end

  describe '#license_metric' do
    let!(:license_metric) do
      create(:license_metric)
    end

    it 'finds the license metric' do
      expect(QualityMetric.license_metric).to eq(license_metric)
    end
  end

  describe '#supported_platforms_metric' do
    let!(:supported_platforms_metric) do
      create(:supported_platforms_metric)
    end

    it 'finds the supported platforms metric' do
      expect(QualityMetric.supported_platforms_metric).to eq(supported_platforms_metric)
    end
  end

  describe '#contributor_file_metric' do
    let!(:contributor_file_metric) do
      create(:contributor_file_metric)
    end

    it 'finds the contributor file metric' do
      expect(QualityMetric.contributor_file_metric).to eq(contributor_file_metric)
    end
  end

end
