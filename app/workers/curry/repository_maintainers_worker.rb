require 'octokit'
require 'tomlrb'

class Curry::RepositoryMaintainersWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  attr_reader :people

  def initialize(config_options = {})
    @config_options = {
      access_token: ENV['GITHUB_ACCESS_TOKEN'],
      default_media_type: 'application/vnd.github.v3.raw'
    }.merge(config_options)
  end

  def perform
    client = Octokit::Client.new(@config_options)
    Curry::Repository.find_each do |repo|
      begin
        raw = client.contents(repo.full_name, path: 'MAINTAINERS.toml')
        data = Tomlrb.parse(raw)
        @people ||= data['people']
        repo.maintainers << components(data['Org']['Components'])
      rescue Octokit::NotFound
        next
      end
    end
  end

  def components(cmp)
    mnt = []
    %w(title text paths team).each { |k| cmp.delete(k) }
    mnt << resolve(cmp.delete('lieutenant')) if cmp.key?('lieutenant')
    mnt << resolve(cmp.delete('maintainers')) if cmp.key?('maintainers')
    cmp.each { |_k, v| mnt << components(v) }
    mnt.flatten.compact.uniq
  end

  def resolve(obj)
    if obj.is_a? Array
      obj.map { |u| User.find_by_github_login(github_user(u)) rescue next } # rubocop:disable Style/RescueModifier
    elsif obj.is_a? String
      User.find_by_github_login(github_user(obj))
    else
      nil
    end
  rescue NoMethodError
    nil
  end

  def github_user(name)
    people[name]['GitHub']
  end
end
