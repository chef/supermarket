class ContributorRequestNotifier
  include Sidekiq::Worker

  def perform(contributor_request_id)
    contributor_request = ContributorRequest.find(contributor_request_id)

    contributor_request.presiding_admins.each do |admin|
      ContributorRequestMailer.delay.incoming_request_email(
        admin,
        contributor_request
      )
    end
  end
end
