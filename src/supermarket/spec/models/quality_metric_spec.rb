require 'spec_helper'

describe QualityMetric do
  it { should have_many(:metric_results) }

  describe 'validations' do
    it 'enforces unique names' do
      create(:quality_metric, name: 'Foodcritic')
      dup_qm = QualityMetric.new(name: 'Foodcritic')
      expect(dup_qm).to_not be_valid
    end
  end

  describe '#foodcritic metric' do
    let!(:foodcritic_metric) do
      create(:quality_metric, name: 'Foodcritic')
    end

    it 'finds the foodcritic metric' do
      expect(QualityMetric.foodcritic_metric).to eq(foodcritic_metric)
    end
  end

  describe '#collaborators_num_metric' do
    let!(:collaborator_metric) do
      create(:quality_metric, name: 'Collaborator Number')
    end

    it 'finds the collaborators num metric' do
      expect(QualityMetric.collaborator_num_metric).to eq(collaborator_metric)
    end
  end
end
