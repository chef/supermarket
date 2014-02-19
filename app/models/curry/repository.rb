require 'net/http'

class Curry::Repository < ActiveRecord::Base
  validates :name, presence: true
  validates :owner, presence: true
  validates :callback_url, presence: true

  has_many :pull_requests, dependent: :destroy

  def full_name
    [owner, name].join('/')
  end
end
