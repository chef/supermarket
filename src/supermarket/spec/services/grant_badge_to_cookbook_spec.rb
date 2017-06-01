require 'spec_helper'

describe GrantBadgeToCookbook do
  let(:cookbook) { create(:cookbook) }
  let(:badge_name) { 'partner' }
  let(:badge_granter) { GrantBadgeToCookbook.new(badge: badge_name, cookbook: cookbook.name) }

  context 'finding the cookbook' do
    it 'searches for the cookbook by name' do
      expect(Cookbook).to receive(:find_by).with(name: cookbook.name).and_return(cookbook)
      badge_granter.call
    end

    context 'when it does not exist' do
      before do
        allow(Cookbook).to receive(:find_by).and_return([])
      end

      it 'returns an error' do
        expect(badge_granter.call).to include("#{cookbook.name} cookbook was not found")
      end
    end
  end

  context 'granting the badge to a cookbook' do
    before do
      allow(Cookbook).to receive(:find_by).with(name: cookbook.name).and_return(cookbook)
    end

    context 'when successful' do
      it 'saves the cookbook' do
        expect(cookbook).to receive(:save)
        badge_granter.call
      end

      it 'returns a success message' do
        expect(badge_granter.call).to include("#{cookbook.name} was granted the #{badge_name} badge.")
      end

      it 'adds the badge to the cookbook' do
        expect(cookbook.badges).to_not include(badge_name)
        badge_granter.call
        cookbook.reload
        expect(cookbook.badges).to include(badge_name)
      end
    end

    context 'when not successful' do
      before do
        allow(Cookbook).to receive(:find_by).and_return(cookbook)
        allow(cookbook).to receive(:save).and_return(false)
      end

      it 'returns an error' do
        expect(badge_granter.call).to include("#{cookbook.name} was not able to be granted the #{badge_name} badge")
      end
    end

    context 'when the cookbook already has the badge' do
      before do
        cookbook.badges += [badge_name]
        cookbook.save!
        expect(cookbook.badges).to include(badge_name)
      end

      it 'returns a message' do
        expect(badge_granter.call).to include("#{cookbook.name} already has the #{badge_name} badge")
      end
    end

    context 'when the badge name is invalid' do
      let(:badge_granter) { GrantBadgeToCookbook.new(badge: 'invalid_badge', cookbook: cookbook.name) }

      it 'returns an error' do
        expect(badge_granter.call).to include('invalid_badge is not a valid badge')
      end
    end
  end
end
