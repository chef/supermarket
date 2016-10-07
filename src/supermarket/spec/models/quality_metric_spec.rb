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
end
