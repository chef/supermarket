class ContributorRequestResponse < ActiveRecord::Base
  validates :contributor_request_id, uniqueness: true
end
