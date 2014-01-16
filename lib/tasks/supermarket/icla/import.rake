namespace :supermarket do
  namespace :icla do
    desc 'Import existing ICLAs'
    task :import => :environment do
      raise ArguementError, 'You must specify CSV_FILE!' unless ENV['CSV_FILE']

      ActiveRecord::Base.transaction do
        CSV.foreach(File.expand_path(ENV['CSV_FILE'])) do |row|
          number         = row[0]
          name           = row[1]
          email          = row[2]
          phone          = row[3]
          company        = row[4]
          signed_at      = row[5]
          address_line_1 = row[6]
          address_line_2 = row[6]
          city           = row[7]
          state          = row[8]
          zip            = row[9]
          country        = row[10]

          first_name, last_name = split_name(name)

          if Email.find(email: email)
            puts "WARN: '#{email}' already exists, skipping"
            next
          end

          user = User.create! do |user|
            user.first_name = first_name
            user.last_name  =  last_name
          end

          user.emails.create! do |email|
            email.email = email
          end

          user.icla_signatures.create! do |icla_signature|
            icla_signature.first_name     = first_name
            icla_signature.last_name      = last_name
            icla_signature.signed_at      = Time.parse(signed_at).utc
            icla_signature.email          = email
            icla_signature.phone          = phone
            icla_signature.company        = company
            icla_signature.address_line_1 = address_line_1
            icla_signature.address_line_2 = address_line_2
            icla_signature.city           = city
            icla_signature.state          = state
            icla_signature.zip            = zip
            icla_signature.country        = country
          end
        end
      end
    end
  end

  def split_name(name)
    if name.include?(' ')
      last_name  = name.split(' ').last
      first_name = name.split(' ')[0...-1].join(' ')
    else
      first_name = name
      last_name  = nil
    end

    [first_name, last_name]
  end
end
