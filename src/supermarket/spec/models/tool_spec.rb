require 'spec_helper'

describe Tool do
  context 'associations' do
    it { should belong_to(:owner) }
    it { should have_one(:chef_account) }
    it { should have_many(:collaborators) }
    it { should have_many(:collaborator_users) }
    it { should have_many(:group_resources) }
  end

  context 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_inclusion_of(:type).in_array(Tool::ALLOWED_TYPES) }
    it { should_not allow_value('great tool').for(:slug) }
    it { should allow_value('great-tool').for(:slug) }
    it { should validate_uniqueness_of(:slug) }

    it 'validates the uniqueness of name' do
      create(:tool)
      expect(subject).to validate_uniqueness_of(:name).case_insensitive
    end

    it 'validates that source_url is a http(s) url' do
      tool = build(:tool, source_url: 'com.http.com')

      expect(tool).to_not be_valid
      expect(tool.errors[:source_url]).to_not be_nil
    end

    it 'generates a slug automatically from the name if a slug does not exist' do
      tool = build(:tool, slug: nil, name: 'awesome tool')
      expect(tool.slug).to be_nil
      expect(tool).to be_valid
      expect(tool.slug).to eql('awesome-tool')
    end
  end

  describe '#lowercase_name' do
    it 'is set as part of the saving lifecycle' do
      tool = Tool.new(name: 'Dingus')
      expect { tool.save }.to change(tool, :lowercase_name).from(nil).to('dingus')
    end
  end

  describe '#name' do
    it "doesn't contain leading or trailing whitespace" do
      tool = create(:tool, name: ' Dingus ')
      expect(tool.name).to eql('Dingus')
    end
  end

  describe '.with_name' do
    it 'is case-insensitive' do
      tool = create(:tool, name: 'DINGUS')
      expect(Tool.with_name('dinGus')).to include(tool)
    end

    it 'can locate multiple tools at once' do
      tool = create(:tool, name: 'DINGUS')
      mytool = create(:tool, name: 'OH YES')
      scope = Tool.with_name(['dingus', 'oh yes'])
      expect(scope).to include(tool, mytool)
    end
  end

  describe '.others_from_this_owner' do
    it 'should find other tools by this owner' do
      user = create(:user)
      tool = create(:tool, name: 'DINGUS', owner: user)
      mytool = create(:tool, name: 'OH YES', owner: user)
      expect(tool.others_from_this_owner.to_a).to eql([mytool])
    end
  end

  describe '.search' do
    let!(:berkshelf) do
      create(
        :tool,
        name: 'Berkshelf',
        description: 'Berkshelf is an okay Chef cookbook dependency manager.',
        owner: create(
          :user,
          chef_account: create(:account, provider: 'chef_oauth2', username: 'johndoe'),
          create_chef_account: false
        )
      )
    end

    let!(:better_berkshelf) do
      create(
        :tool,
        name: 'Better Berkshelf',
        description: 'Berkshelf is a Chef cookbook dependency manager.',
        owner: create(
          :user,
          chef_account: create(:account, provider: 'chef_oauth2', username: 'fanny'),
          create_chef_account: false
        )
      )
    end

    it 'returns tools with a similar name' do
      expect(Tool.search('berkshelf')).to include(berkshelf)
      expect(Tool.search('berkshelf')).to include(better_berkshelf)
    end

    it 'returns tools with a similar description' do
      expect(Tool.search('okay')).to include(berkshelf)
      expect(Tool.search('okay')).to_not include(better_berkshelf)
    end

    it 'returns tools with a similar maintainer' do
      expect(Tool.search('johndoe')).to include(berkshelf)
      expect(Tool.search('johndoe')).to_not include(better_berkshelf)
    end
  end
end
