#
# Coordinates communication following a new +ContributorRequest+
#
class ContributorRequestNotifier
  include Sidekiq::Worker

  #
  # Queues an email to each admin of the organization indicated by the given
  # +ContributorRequest+.
  #
  # @param contributor_request_id [Fixnum] Identifies a +ContributorRequest+
  #
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
