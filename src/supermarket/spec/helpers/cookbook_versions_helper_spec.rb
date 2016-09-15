require 'spec_helper'

describe CookbookVersionsHelper do
  describe '#render_document' do
    it 'converts markdown to html when the extension is "md"' do
      expect(render_document('*hi*', 'md')).to eql("<p><em>hi</em></p>\n")
    end

    it 'returns the content if no extension is specified' do
      expect(render_document('_hi_', '')).to eql('_hi_')
    end
  end

  describe '#safe_updated_at' do
    it 'works if the collection has stuff in it' do
      expect(helper.safe_updated_at([create(:cookbook)])).to be <= Time.zone.now
    end

    it 'works if the collection is empty' do
      expect(helper.safe_updated_at([])).to be <= Time.zone.now
    end

    it 'works if the collection is nil' do
      expect(helper.safe_updated_at(nil)).to be <= Time.zone.now
    end
  end

  describe '#foodcritic_metric_result' do
    let(:cookbook) { create(:cookbook) }

    let(:quality_metric) { QualityMetric.create(name: 'Foodcritic') }

    let!(:metric_result) do
      MetricResult.create(
        cookbook_version: cookbook.latest_cookbook_version,
        quality_metric: quality_metric,
        failure: true,
        feedback: 'it failed'
      )
    end

    before do
      expect(cookbook.latest_cookbook_version.metric_results).to_not be_empty
    end

    it 'returns the correct metric' do
      expect(helper.foodcritic_metric_result(cookbook.latest_cookbook_version)).to eq(metric_result)
    end
  end

  describe '#collaborator_num_metric_result' do
    let(:cookbook) { create(:cookbook) }

    let(:quality_metric) { QualityMetric.create(name: 'Collaborator Number') }

    let!(:metric_result) do
      MetricResult.create(
        cookbook_version: cookbook.latest_cookbook_version,
        quality_metric: quality_metric,
        failure: true,
        feedback: 'it failed'
      )
    end

    before do
      expect(cookbook.latest_cookbook_version.metric_results).to_not be_empty
    end

    it 'returns the correct metric' do
      expect(helper.collaborator_num_metric_result(cookbook.latest_cookbook_version)).to eq(metric_result)
    end
  end
end
