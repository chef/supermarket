require 'spec_helper'

describe RunQualityMetrics do
  context 'when fieri is enabled' do
    before :each do
      expect(Feature).to receive(:active?).with(:fieri).and_return(true)
    end

    context 'on the latest version of a single cookbook' do
      let(:cookbook) { create :cookbook }
      let(:latest_version) { cookbook.latest_cookbook_version }

      it 'schedules notifying fieri to do the thing' do
        expect(FieriNotifyWorker).to receive(:perform_async).with(latest_version.id)
        RunQualityMetrics.on_latest(cookbook.name)
      end

      it 'returns a message about successful scheduling' do
        allow(FieriNotifyWorker).to receive(:perform_async)
        success_message = I18n.t('fieri.scheduled.single', name: cookbook.name, version: latest_version.version)

        expect(RunQualityMetrics.on_latest(cookbook.name))
          .to eql([:ok, success_message])
      end

      it 'returns an error when a cookbook is not found with a given name' do
        expect(FieriNotifyWorker).not_to receive(:perform_async)
        error_message = I18n.t('cookbook.not_found', name: 'nope')

        expect(RunQualityMetrics.on_latest('nope'))
          .to eql([:error, error_message])
      end
    end

    context 'on a given version of a single cookbook' do
      let(:cookbook) { create :cookbook }
      let(:cookbook_version) { cookbook.cookbook_versions.first }

      it 'schedules notifying fieri to do the thing' do
        expect(FieriNotifyWorker).to receive(:perform_async).with(cookbook_version.id)
        RunQualityMetrics.on_version(cookbook.name, cookbook_version.version)
      end

      it 'returns a message about successful scheduling' do
        allow(FieriNotifyWorker).to receive(:perform_async)
        success_message = I18n.t('fieri.scheduled.single', name: cookbook.name, version: cookbook_version.version)

        expect(RunQualityMetrics.on_version(cookbook.name, cookbook_version.version))
          .to eql([:ok, success_message])
      end

      it 'returns an error when a cookbook is not found with a given name' do
        expect(FieriNotifyWorker).not_to receive(:perform_async)
        error_message = I18n.t('cookbook.not_found', name: 'nope')

        expect(RunQualityMetrics.on_version('nope', '9.9.9'))
          .to eql([:error, error_message])
      end

      it 'returns an error when a cookbook is not found with a given version' do
        create(:cookbook, name: 'got-no-nines')
        expect(FieriNotifyWorker).not_to receive(:perform_async)
        error_message = I18n.t('cookbook.version_not_found', name: 'got-no-nines', version: '9.9.9')

        expect(RunQualityMetrics.on_version('got-no-nines', '9.9.9'))
          .to eql([:error, error_message])
      end
    end

    context 'on all the latest cookbook versions' do
      before :each do
        13.times do
          create(:cookbook)
        end
      end

      it 'schedules notifying fieri to do the thing' do
        expect(FieriNotifyWorker).to receive(:perform_async).exactly(13).times
        RunQualityMetrics.all_the_latest
      end

      it 'returns a message about successful scheduling' do
        allow(FieriNotifyWorker).to receive(:perform_async)
        success_message = I18n.t('fieri.scheduled.multiple', count: 13)

        expect(RunQualityMetrics.all_the_latest)
          .to eq([:ok, success_message])
      end
    end
  end

  context 'when fieri is not enabled' do
    before :each do
      expect(Feature).to receive(:active?).with(:fieri).and_return(false)
    end

    let(:error_message) { I18n.t('fieri.not_enabled') }

    it 'shows a disabled notice for all the latest' do
      expect(RunQualityMetrics.all_the_latest)
        .to eql([:error, error_message])
    end

    it 'shows a disabled notice for one cookbook latest' do
      expect(RunQualityMetrics.on_latest('nope'))
        .to eql([:error, error_message])
    end

    it 'shows a disabled notice for one cookbook version' do
      expect(RunQualityMetrics.on_version('nope', '1.2.3'))
        .to eql([:error, error_message])
    end
  end
end
