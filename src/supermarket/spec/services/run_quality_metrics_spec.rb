require 'spec_helper'

describe RunQualityMetrics do
  context 'schedules quality metric runs for' do
    it 'the latest version of a single cookbook' do
      cookbook = create(:cookbook)
      latest_version = cookbook.latest_cookbook_version

      expect(FieriNotifyWorker).to receive(:perform_async).with(latest_version.id)
      RunQualityMetrics.on_latest(cookbook.name)
    end

    it 'a given version of a single cookbook' do
      cookbook = create(:cookbook)
      cookbook_version = cookbook.cookbook_versions.first

      expect(FieriNotifyWorker).to receive(:perform_async).with(cookbook_version.id)
      RunQualityMetrics.on_version(cookbook.name, cookbook_version.version)
    end

    it 'all the latest cookbook versions' do
      13.times do
        create(:cookbook)
      end

      expect(FieriNotifyWorker).to receive(:perform_async).exactly(13).times
      RunQualityMetrics.all_the_latest
    end
  end
end
