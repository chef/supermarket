require 'net/http'

class Curry::Repository < ActiveRecord::Base
  validates :name, presence: true
  validates :owner, presence: true
  validates :callback_url, presence: true

  has_many :pull_requests, dependent: :destroy

  def full_name
    if owner.present? && name.present?
      [owner, name].join('/')
    end
  end

  def full_name=(full_name)
    self.owner, self.name = full_name.split('/')
  end
end
