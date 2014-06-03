require 'spec_helper'

describe 'cleanup:supported_platforms' do
  include_context 'rake'

  let(:platforms) { %w(ubuntu centos rhel) }
  let(:versions) { ['>= 5.0', '>= 6.0', '= 7.5'] }
  let(:cookbook) { create(:cookbook) }

  def fetch_randomly(sym)
    ary = method(sym).call
    ary[rand(ary.size)]
  end

  it 'should cleanup supported platforms' do
    max_records = 100

    1.upto(max_records) do |i|
      cv = create(:cookbook_version, cookbook: cookbook)
      create(:supported_platform, name: fetch_randomly(:platforms), version_constraint: fetch_randomly(:versions), cookbook_version_id: cv.id)
    end

    expect(SupportedPlatform.count).to eql(max_records)
    distinct_platforms = SupportedPlatform.pluck(:name).uniq.size
    distinct_versions = SupportedPlatform.pluck(:version_constraint).uniq.size

    subject.invoke

    expect(SupportedPlatform.count).to eql(distinct_platforms * distinct_versions)
    expect(CookbookVersionPlatform.count).to eql(max_records)
  end
end
