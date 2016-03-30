require 'spec_helper'

describe AdoptionHelper do
  before do
    fake_policy = double(:policy, :manage_adoption? => true)
    allow(helper).to receive(:policy) { fake_policy }
  end

  context 'Cookbooks' do
    it 'generates a link to enable adoption for a Cookbook' do
      cookbook = create(:cookbook, name: 'haha', up_for_adoption: false)
      link = helper.link_to_adoption(cookbook)
      expected_link = '<li><a data-method="patch" href="/cookbooks/haha?cookbook%5Bup_for_adoption%5D=true" rel="nofollow"><i class="fa fa-heart"></i> Put up for adoption</a></li>'
      expect(link).to eql(expected_link)
    end

    it 'generates a link to disable adoption for a Cookbook' do
      cookbook = create(:cookbook, name: 'haha', up_for_adoption: true)
      link = helper.link_to_adoption(cookbook)
      expected_link = '<li><a data-method="patch" href="/cookbooks/haha?cookbook%5Bup_for_adoption%5D=false" rel="nofollow"><i class="fa fa-heart"></i> Disable adoption</a></li>'
      expect(link).to eql(expected_link)
    end
  end

  context 'Tools' do
    it 'generates a link to enable adoption for a Tool' do
      tool = create(:tool, name: 'haha', up_for_adoption: false)
      link = helper.link_to_adoption(tool)
      expected_link = '<li><a data-method="patch" href="/tools/haha?tool%5Bup_for_adoption%5D=true" rel="nofollow"><i class="fa fa-heart"></i> Put up for adoption</a></li>'
      expect(link).to eql(expected_link)
    end

    it 'generates a link to disable adoption for a Tool' do
      tool = create(:tool, name: 'haha', up_for_adoption: true)
      link = helper.link_to_adoption(tool)
      expected_link = '<li><a data-method="patch" href="/tools/haha?tool%5Bup_for_adoption%5D=false" rel="nofollow"><i class="fa fa-heart"></i> Disable adoption</a></li>'
      expect(link).to eql(expected_link)
    end
  end
end
