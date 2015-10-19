require 'csv'

class ClaReport < ActiveRecord::Base
  # Attachments
  # --------------------
  has_attached_file :csv

  # Validations
  # --------------------
  validates_attachment_content_type :csv, content_type: /csv/

  #
  # Returns a new +ClaReport+ with the next range of ICLA and CCLA signatures
  # and a generated CSV attachment if there are no new signatures to generate
  # a report for a new report isn't created and nil is returned.
  #
  # @return [ClaReport]
  #
  def self.generate
    last_report = ClaReport.last

    if last_report
      new_icla_signatures = IclaSignature.
        where('id > ?', last_report.last_icla_id).order('id ASC')
      new_ccla_signatures = CclaSignature.
        where('id > ?', last_report.last_ccla_id).order('id ASC')
    else
      new_icla_signatures = IclaSignature.order('id ASC')
      new_ccla_signatures = CclaSignature.order('id ASC')
    end

    return nil if new_icla_signatures.empty? && new_ccla_signatures.empty?

    report = ClaReport.new(
      first_icla_id: new_icla_signatures.first.try(:id),
      last_icla_id: new_icla_signatures.last.try(:id),
      first_ccla_id: new_ccla_signatures.first.try(:id),
      last_ccla_id: new_ccla_signatures.last.try(:id)
    )

    csv_string = CSV.generate do |csv|
      csv << ['Name', 'Company', 'Address Line 1', 'Address Line 2', 'City', 'State', 'Zip', 'Country']

      report.icla_signatures.each do |icla_signature|
        csv << [
          icla_signature.name,
          '',
          icla_signature.address_line_1,
          icla_signature.address_line_2,
          icla_signature.city,
          icla_signature.state,
          icla_signature.zip,
          icla_signature.country
        ]
      end

      report.ccla_signatures.each do |ccla_signature|
        csv << [
          ccla_signature.name,
          ccla_signature.company,
          ccla_signature.address_line_1,
          ccla_signature.address_line_2,
          ccla_signature.city,
          ccla_signature.state,
          ccla_signature.zip,
          ccla_signature.country
        ]
      end
    end

    report.csv = StringIO.new(csv_string)
    report.csv_content_type = 'text/csv'
    report.csv_file_name = "#{Time.current.to_i}.csv"
    report.save!

    report
  end

  #
  # Returns all +IclaSignature+ instances between the reports first
  # and last icla id.
  #
  # @return [ActiveRecord::Association<IclaSignature>]
  #
  def icla_signatures
    IclaSignature.where('id >= ? AND id <= ?', first_icla_id, last_icla_id)
  end

  #
  # Returns all +CclaSignature+ instances between the reports first
  # and last ccla id.
  #
  # @return [ActiveRecord::Association<CclaSignature>]
  #
  def ccla_signatures
    CclaSignature.where('id >= ? AND id <= ?', first_ccla_id, last_ccla_id)
  end
end
