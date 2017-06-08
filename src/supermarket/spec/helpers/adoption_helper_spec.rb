require 'spec_helper'

describe AdoptionHelper do
  before do
    fake_policy = double(:policy, manage_adoption?: true)
    allow(helper).to receive(:policy) { fake_policy }
  end

  context 'Cookbooks' do
    it 'generates a link to enable adoption for a Cookbook' do
      cookbook = create(:cookbook, name: 'haha', up_for_adoption: false)
      link = helper.link_to_adoption(cookbook)
      expect(link).to include('data-confirm="Are you sure you want to put this up for adoption?"')
      expect(link).to include('href="/cookbooks/haha?cookbook%5Bup_for_adoption%5D=true"')
      expect(link).to include('Put up for adoption')
    end

    it 'generates a link to disable adoption for a Cookbook' do
      cookbook = create(:cookbook, name: 'haha', up_for_adoption: true)
      link = helper.link_to_adoption(cookbook)
      expect(link).to include('data-confirm="Are you sure you want to put this up for adoption?"')
      expect(link).to include('href="/cookbooks/haha?cookbook%5Bup_for_adoption%5D=false"')
      expect(link).to include('Disable adoption')
    end
  end

  context 'Tools' do
    it 'generates a link to enable adoption for a Tool' do
      tool = create(:tool, name: 'haha', up_for_adoption: false)
      link = helper.link_to_adoption(tool)
      expect(link).to include('data-confirm="Are you sure you want to put this up for adoption?"')
      expect(link).to include('href="/tools/haha?tool%5Bup_for_adoption%5D=true"')
      expect(link).to include('Put up for adoption')
    end

    it 'generates a link to disable adoption for a Tool' do
      tool = create(:tool, name: 'haha', up_for_adoption: true)
      link = helper.link_to_adoption(tool)
      expect(link).to include('data-confirm="Are you sure you want to put this up for adoption?"')
      expect(link).to include('href="/tools/haha?tool%5Bup_for_adoption%5D=false"')
      expect(link).to include('Disable adoption')
    end
  end
end
