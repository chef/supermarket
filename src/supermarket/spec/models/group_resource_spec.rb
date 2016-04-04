require 'spec_helper'

describe GroupResource do
  context 'associations' do
    it { should belong_to(:group) }
    it { should belong_to(:resourceable) }

    context 'validations' do
      let(:cookbook) { create(:cookbook) }
      let(:group) { create(:group) }

      it 'requires a group id' do
        group_resource = GroupResource.new(group: nil, resourceable: cookbook)
        expect(group_resource).to_not be_valid
      end

      it 'requires a resourceable' do
        group_resource = GroupResource.new(group: group, resourceable: nil)
        expect(group_resource).to_not be_valid
      end
    end

    describe '#resourceable' do
      let(:group) { create(:group) }

      context 'when the resourceable is a cookbook' do
        let(:cookbook) { create(:cookbook) }

        it 'returns the cookbook' do
          group_resource = GroupResource.new(group: group, resourceable: cookbook)
          expect(group_resource.resourceable).to eq(cookbook)
        end
      end

      context 'when the resourceable is a tool' do
        let(:tool) { create(:tool) }

        it 'returns the tool' do
          group_resource = GroupResource.new(group: group, resourceable: tool)
          expect(group_resource.resourceable).to eq(tool)
        end
      end
    end
  end
end
