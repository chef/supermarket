namespace :signers do
  namespace :export do

    # Usage: rake signers:export:icla after="#{date after which to find new ICLA signers}"
    desc 'Given a date, export as CSV ICLA signatures from users after that date'
    task icla: :environment do
      date = Time.zone.parse(ENV['date'])
      puts IclaSignature.earliest.where('signed_at > ?', date).as_csv
    end

    # Usage: rake signers:export:ccla after="#{date after which to find new CCLA signers}"
    desc 'Given a date, export as CSV CCLA signatures from organizations after that date'
    task ccla: :environment do
      date = Time.zone.parse(ENV['date'])
      puts CclaSignature.earliest.where('signed_at > ?', date).as_csv
    end
  end
end
