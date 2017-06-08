require 'spec_helper'

describe FeatureFlagHelper do
  describe '#air_gap?' do
    context 'when the feature flag is set to true' do
      before do
        ENV['AIR_GAPPED'] = 'true'
      end

      it 'returns true' do
        expect(helper.air_gapped?).to eq(true)
      end
    end

    context 'when the feature flag is not set to true' do
      before do
        ENV['AIR_GAPPED'] = 'false'
      end

      it 'returns false' do
        expect(helper.air_gapped?).to eq(false)
      end
    end
  end
end
