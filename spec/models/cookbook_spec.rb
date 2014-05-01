require 'spec_helper'

describe Cookbook do
  context 'associations' do
    it { should have_many(:cookbook_versions) }
    it { should have_many(:cookbook_followers) }
    it { should belong_to(:category) }
    it { should belong_to(:owner) }
    it { should have_many(:cookbook_collaborators) }
    it { should have_many(:collaborators) }
  end

  context 'validations' do
    it 'validates the uniqueness of name' do
      create(:cookbook)

      expect(subject).to validate_uniqueness_of(:name).case_insensitive
    end

    it 'validates that issues_url is a http(s) url' do
      cookbook = create(:cookbook)
      cookbook_version = create(:cookbook_version, cookbook: cookbook)
      cookbook.issues_url = 'com.http.com'

      expect(cookbook).to_not be_valid
      expect(cookbook.errors[:issues_url]).to_not be_nil
    end

    it 'validates that source_url is a http(s) url' do
      cookbook = create(:cookbook)
      cookbook_version = create(:cookbook_version, cookbook: cookbook)
      cookbook.source_url = 'com.http.com'

      expect(cookbook).to_not be_valid
      expect(cookbook.errors[:source_url]).to_not be_nil
    end

    it 'does not allow spaces in cookbook names' do
      cookbook = Cookbook.new(name: 'great cookbook')
      cookbook.valid?

      expect(cookbook.errors[:name]).to_not be_empty

      cookbook = Cookbook.new(name: 'great-cookbook')
      cookbook.valid?

      expect(cookbook.errors[:name]).to be_empty
    end

    it 'allows letters, numbers, dashes, and underscores in cookbook names' do
      cookbook = Cookbook.new(name: 'Cookbook_-1')
      cookbook.valid?

      expect(cookbook.errors[:name]).to be_empty
    end

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:maintainer) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:cookbook_versions) }
    it { should validate_presence_of(:category) }
  end

  describe '#lowercase_name' do
    it 'is set as part of the saving lifecycle' do
      cookbook = Cookbook.new(name: 'Apache')

      expect do
        cookbook.save
      end.to change(cookbook, :lowercase_name).from(nil).to('apache')
    end
  end

  describe '#to_param' do
    it "returns the cookbook's name downcased and parameterized" do
      cookbook = Cookbook.new(name: 'Spicy Curry')
      expect(cookbook.to_param).to eql('spicy-curry')
    end
  end

  describe '#get_version!' do
    let!(:kiwi_0_1_0) do
      create(
        :cookbook_version,
        version: '0.1.0',
        license: 'MIT'
      )
    end

    let!(:kiwi_0_2_0) do
      create(
        :cookbook_version,
        version: '0.2.0',
        license: 'MIT'
      )
    end

    let!(:kiwi) do
      create(
        :cookbook,
        name: 'kiwi',
        maintainer: 'fruit',
        cookbook_versions_count: 0,
        cookbook_versions: [kiwi_0_2_0, kiwi_0_1_0]
      )
    end

    it 'returns the cookbook version specified' do
      expect(kiwi.get_version!('0_1_0')).to eql(kiwi_0_1_0)
    end

    it "returns the highest version when the version is 'latest'" do
      expect(kiwi.get_version!('latest')).to eql(kiwi_0_2_0)
    end

    it 'raises ActiveRecord::RecordNotFound if the version does not exist' do
      expect { kiwi.get_version!('0_4_0') }.
        to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#publish_version!' do
    let(:cookbook) { create(:cookbook) }
    let(:tarball) { File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz') }
    let(:readme) { CookbookUpload::Readme.new(contents: '', extension: '') }

    let(:metadata) do
      CookbookUpload::Metadata.new(
        license: 'MIT',
        version: cookbook.latest_cookbook_version.version + '-beta',
        description: 'Description',
        maintainer: 'Jane Doe',
        platforms: {
          'ubuntu' => '= 12.04',
          'debian' => '>= 0.0.0'
        },
        dependencies: {
          'apt' => '= 1.2.3',
          'yum' => '~> 2.1.3'
        }
      )
    end

    it 'creates supported platforms from the metadata' do
      cookbook.publish_version!(metadata, tarball, readme)
      supported_platforms = cookbook.reload.supported_platforms

      expect(supported_platforms.map(&:name)).to match_array(%w(debian ubuntu))
      expect(supported_platforms.map(&:version_constraint)).
        to match_array(['= 12.04', '>= 0.0.0'])
    end

    it 'creates cookbook dependencies from the metadata' do
      cookbook.publish_version!(metadata, tarball, readme)

      dependencies = cookbook.reload.cookbook_dependencies

      expect(dependencies.map(&:name)).to match_array(%w(apt yum))
      expect(dependencies.map(&:version_constraint)).
        to match_array(['= 1.2.3', '~> 2.1.3'])
    end
  end

  describe '.search' do
    let!(:redis) do
      create(
        :cookbook,
        name: 'redis',
        maintainer: 'tokein',
        category: create(:category, name: 'datastore'),
        description: 'Redis: a fast, flexible datastore offering an extremely useful set of data structure primitives'
      )
    end

    let!(:redisio) do
      create(
        :cookbook,
        name: 'redisio',
        maintainer: 'fruit',
        category: create(:category, name: 'datastore'),
        description: 'Installs/Configures redis'
      )
    end

    it 'returns cookbooks with a similar name' do
      expect(Cookbook.search('redis')).to include(redis)
      expect(Cookbook.search('redis')).to include(redisio)
    end

    it 'returns cookbooks with a similar maintainer' do
      expect(Cookbook.search('fruit')).to include(redisio)
      expect(Cookbook.search('fruit')).to_not include(redis)
      expect(Cookbook.search('tokein')).to include(redis)
      expect(Cookbook.search('tokein')).to_not include(redisio)
    end

    it 'returns cookbooks with a similar category' do
      expect(Cookbook.search('datastore')).to include(redisio)
      expect(Cookbook.search('datastore')).to include(redis)
    end

    it 'returns cookbooks with a similar description' do
      expect(Cookbook.search('fast')).to include(redis)
      expect(Cookbook.search('fast')).to_not include(redisio)
    end
  end

  describe '.ordered_by' do
    let!(:great) { create(:cookbook, name: 'great') }
    let!(:cookbook) { create(:cookbook, name: 'cookbook') }

    it 'orders by name ascending by default' do
      expect(Cookbook.ordered_by(nil).map(&:name)).to eql(%w(cookbook great))
    end

    it 'orders by updated_at descending when given "recently_updated"' do
      great.touch

      expect(Cookbook.ordered_by('recently_updated').map(&:name)).
        to eql(%w(great cookbook))
    end

    it 'orders by created_at descending when given "recently_added"' do
      create(:cookbook, name: 'neat')

      expect(Cookbook.ordered_by('recently_added').first.name).to eql('neat')
    end

    it 'orders by download_count descending when given "most_downloaded"' do
      great.update_attributes(download_count: 100)
      cookbook.update_attributes(download_count: 50)

      expect(Cookbook.ordered_by('most_downloaded').map(&:name)).
        to eql(%w(great cookbook))
    end

    it 'orders by cookbook_followers_count when given "most_followed"' do
      great.update_attributes(cookbook_followers_count: 100)
      cookbook.update_attributes(cookbook_followers_count: 50)

      expect(Cookbook.ordered_by('most_followed').map(&:name)).
        to eql(%w(great cookbook))
    end
  end

  describe '.with_name' do
    it 'is case-insensitive' do
      cookbook = create(:cookbook, name: 'CookBook')

      expect(Cookbook.with_name('Cookbook')).to include(cookbook)
    end

    it 'can locate multiple cookbooks at once' do
      cookbook = create(:cookbook, name: 'CookBook')
      mybook = create(:cookbook, name: 'MYBook')

      scope = Cookbook.with_name(%w(Cookbook MyBook))

      bad_scope = Cookbook.where(name: %w(cookbook mybook)).count

      expect(scope).to include(cookbook)
      expect(scope).to include(mybook)
    end
  end

  describe '#followed_by?' do
    it 'returns true if the user passed follows the cookbook' do
      user = create(:user)
      cookbook = create(:cookbook)
      create(:cookbook_follower, user: user, cookbook: cookbook)

      expect(cookbook.followed_by?(user)).to be_true
    end

    it "returns false if the user passed doesn't follow the cookbook" do
      user = create(:user)
      cookbook = create(:cookbook)

      expect(cookbook.followed_by?(user)).to be_false
    end
  end
end
