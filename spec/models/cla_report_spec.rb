require 'spec_helper'

describe ClaReport do
  describe '.generate' do
    it 'creates a new ClaReport with the first and last processed ccla and icla signature ids' do
      icla_signature_1 = create(:icla_signature)
      ccla_signature_1 = create(:ccla_signature, organization: create(:organization, ccla_signatures_count: 0))

      report_1 = ClaReport.generate

      expect(report_1.first_icla_id).to eql(icla_signature_1.id)
      expect(report_1.last_icla_id).to eql(icla_signature_1.id)
      expect(report_1.first_ccla_id).to eql(ccla_signature_1.id)
      expect(report_1.last_ccla_id).to eql(ccla_signature_1.id)

      icla_signature_2 = create(:icla_signature)
      ccla_signature_2 = create(:ccla_signature, organization: create(:organization, ccla_signatures_count: 0))

      report_2 = ClaReport.generate

      expect(report_2.first_icla_id).to eql(icla_signature_2.id)
      expect(report_2.last_icla_id).to eql(icla_signature_2.id)
      expect(report_2.first_ccla_id).to eql(ccla_signature_2.id)
      expect(report_2.last_ccla_id).to eql(ccla_signature_2.id)
    end

    it 'returns nil if there are no new signatures to generate a report for' do
      icla_signature_1 = create(:icla_signature)
      ClaReport.generate

      expect(ClaReport.generate).to eql(nil)
    end
  end

  describe '#icla_signatures' do
    it 'includes new icla signatures that have not been included in previous reports' do
      icla_signature_1 = create(:icla_signature)
      ClaReport.generate

      icla_signature_2 = create(:icla_signature)
      report = ClaReport.generate

      expect(report.icla_signatures).to include(icla_signature_2)
      expect(report.icla_signatures).to_not include(icla_signature_1)
    end
  end

  describe '#ccla_signatures' do
    it 'includes new ccla signatures that have not been included in previous reports' do
      ccla_signature_1 = create(:ccla_signature, organization: create(:organization, ccla_signatures_count: 0))
      ClaReport.generate

      ccla_signature_2 = create(:ccla_signature, organization: create(:organization, ccla_signatures_count: 0))
      report = ClaReport.generate

      expect(report.ccla_signatures).to include(ccla_signature_2)
      expect(report.ccla_signatures).to_not include(ccla_signature_1)
    end
  end
end
