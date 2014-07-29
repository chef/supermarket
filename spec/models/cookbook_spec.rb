require 'spec_helper'

describe Cookbook do
  context 'associations' do
    it { should have_many(:cookbook_versions) }
    it { should have_many(:cookbook_followers) }
    it { should have_many(:followers) }
    it { should belong_to(:category) }
    it { should belong_to(:owner) }
    it { should have_many(:cookbook_collaborators) }
    it { should have_many(:collaborators) }

    context 'dependent deletions' do
      let!(:cookbook) { create(:cookbook) }
      let!(:follower) { create(:cookbook_follower, cookbook: cookbook, user: create(:user)) }
      let!(:collaborator) { create(:cookbook_collaborator, cookbook: cookbook, user: create(:user)) }

      before do
        cookbook.reload
      end

      it 'should not destroy followers when deleted' do
        expect(cookbook.cookbook_followers.size).to eql(1)
        cookbook.destroy
        expect { follower.reload }.to_not raise_error
      end

      it 'should not destroy collaborators when deleted' do
        expect(cookbook.cookbook_collaborators.size).to eql(1)
        cookbook.destroy
        expect { collaborator.reload }.to_not raise_error
      end
    end
  end

  context 'ordering versions' do
    let(:toast) { create(:cookbook) }

    before do
      toast.cookbook_versions.each(&:destroy)
      create(:cookbook_version, cookbook: toast, version: '0.1.0')
      create(:cookbook_version, cookbook: toast, version: '10.0.0')
      create(:cookbook_version, cookbook: toast, version: '9.9.9')
      create(:cookbook_version, cookbook: toast, version: '9.10.0')
      create(:cookbook_version, cookbook: toast, version: '0.2.0')
      toast.reload
    end

    it 'should order versions based on the version number' do
      versions = toast.sorted_cookbook_versions.map(&:version)
      expect(toast.cookbook_versions.size).to eql(5)
      expect(versions).to eql(['10.0.0', '9.10.0', '9.9.9', '0.2.0', '0.1.0'])
    end

    it 'should use the one with the largest version number for #latest_cookbook_version' do
      expect(toast.latest_cookbook_version.version).to eql('10.0.0')
    end
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

    it 'requires deprecated cookbooks to specify a replacement' do
      cookbook = Cookbook.new(deprecated: true)
      cookbook.valid?

      expect(cookbook.errors[:replacement]).to_not be_empty

      cookbook.replacement = Cookbook.new
      cookbook.valid?

      expect(cookbook.errors[:replacement]).to be_empty
    end

    it { should validate_presence_of(:name) }
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

  describe '#deprecate' do
    let!(:cookbook) { create(:cookbook, name: 'spicy_curry') }

    context 'replacement cookbook is valid' do
      let!(:replacement_cookbook) { create(:cookbook, name: 'mild_curry') }

      it 'returns true' do
        result = cookbook.deprecate(replacement_cookbook)
        expect(result).to eql(true)
      end

      it 'sets the deprecated attribute to true' do
        cookbook.deprecate(replacement_cookbook)

        expect(cookbook.deprecated?).to eql(true)
      end

      it 'sets the replacement' do
        cookbook.deprecate(replacement_cookbook)

        expect(cookbook.replacement).to eql(replacement_cookbook)
      end
    end

    context 'replacement cookbook is deprecated' do
      let!(:replacement_cookbook) do
        create(
          :cookbook,
          name: 'green_curry',
          deprecated: 'true',
          replacement: create(:cookbook)
        )
      end

      it 'returns false' do
        result = cookbook.deprecate(replacement_cookbook)
        expect(result).to eql(false)
      end

      it 'fails to deprecate' do
        cookbook.deprecate(replacement_cookbook)

        expect(cookbook.deprecated?).to eql(false)
      end

      it 'fails to set the replacement' do
        cookbook.deprecate(replacement_cookbook)

        expect(cookbook.replacement).to eql(nil)
      end

      it 'adds an error if the replacement cookbook is deprecated' do
        expect do
          cookbook.deprecate(replacement_cookbook)
        end.to change(cookbook.errors, :count).by(1)
      end
    end
  end

  describe '#deprecate_search', search: true do
    let!(:postgresql) { create(:cookbook, name: 'postgresql') }
    let!(:postgres) { create(:cookbook, name: 'postgres') }
    let!(:postgresql_lol) do
      create(
        :cookbook,
        name: 'postgresql_lol',
        deprecated: 'true',
        replacement: create(:cookbook)
      )
    end

    before do
      Cookbook.reindex
      Sunspot.commit
    end

    it 'returns relevant cookbooks' do
      results = postgresql.deprecate_search('postgres')
      expect(results).to include(postgres)
    end

    it 'does not return the cookbook being deprecated' do
      results = postgresql.deprecate_search('postgres')
      expect(results).to_not include(postgresql)
    end

    it 'only returns non-deprecated cookbooks' do
      results = postgresql.deprecate_search('postgres')
      expect(results).to_not include(postgresql_lol)
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
        cookbook_versions_count: 0,
        cookbook_versions: [kiwi_0_2_0, kiwi_0_1_0]
      )
    end

    it 'returns the cookbook version specified' do
      expect(kiwi.get_version!('0_1_0')).to eql(kiwi_0_1_0)
    end

    it 'returns the cookbook version specified even if dots are used' do
      expect(kiwi.get_version!('0.1.0')).to eql(kiwi_0_1_0)
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
        version: '9.9.9',
        description: 'Description',
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

    it 'bumps the updated at date' do
      original_date = cookbook.updated_at
      cookbook.publish_version!(metadata, tarball, readme)

      expect(cookbook.updated_at).to be > original_date
    end
  end

  describe '.search', search: true do
    let!(:redis) do
      create(
        :cookbook,
        name: 'redis',
        category: create(:category, name: 'datastore'),
        owner: create(:user, chef_account: create(:account, provider: 'chef_oauth2', username: 'johndoe'), create_chef_account: false),
        cookbook_versions: [
          create(
            :cookbook_version,
            description: 'Redis: a fast, flexible datastore offering an extremely useful set of data structure primitives'
          )
        ]
      )
    end

    let!(:redisio) do
      create(
        :cookbook,
        name: 'redisio',
        category: create(:category, name: 'datastore'),
        owner: create(:user, chef_account: create(:account, provider: 'chef_oauth2', username: 'fanny'), create_chef_account: false),
        cookbook_versions: [
          create(
            :cookbook_version,
            description: 'Installs/Configures redis. Created by the formidable johndoe, johndoe is pretty awesome.'
          )
        ],
        cookbook_versions_count: 0
      )
    end

    before do
      Cookbook.reindex
      Sunspot.commit
    end

    it 'returns cookbooks with a similar name' do
      results = Cookbook.search do
        fulltext 'redis'
      end.results

      expect(results).to include(redis)
      expect(results).to include(redisio)
    end

    it 'returns cookbooks with a similar description' do
      results = Cookbook.search do
        fulltext 'fast'
      end.results

      expect(results).to include(redis)
      expect(results).to_not include(redisio)
    end

    it 'returns cookbooks with a similar maintainer' do
      results = Cookbook.search do
        fulltext 'fanny'
      end.results

      expect(results).to include(redisio)
      expect(results).to_not include(redis)
    end

    it 'weights cookbook name over cookbook description' do
      results = Cookbook.search do
        fulltext 'redis'
      end.results

      expect(results[0]).to eql(redis)
      expect(results[1]).to eql(redisio)
    end

    it 'weights cookbook maintainer over cookbook description' do
      results = Cookbook.search do
        fulltext 'johndoe'
      end.results

      expect(results[0]).to eql(redis)
      expect(results[1]).to eql(redisio)
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
      great.update_attributes(web_download_count: 1, api_download_count: 100)
      cookbook.update_attributes(web_download_count: 5, api_download_count: 70)

      expect(Cookbook.ordered_by('most_downloaded').map(&:name)).
        to eql(%w(great cookbook))
    end

    it 'orders by cookbook_followers_count when given "most_followed"' do
      great.update_attributes(cookbook_followers_count: 100)
      cookbook.update_attributes(cookbook_followers_count: 50)

      expect(Cookbook.ordered_by('most_followed').map(&:name)).
        to eql(%w(great cookbook))
    end

    it 'orders secondarily by id when cookbook follower counts are equal' do
      great.update_attributes(cookbook_followers_count: 100)
      cookbook.update_attributes(cookbook_followers_count: 100)

      expect(Cookbook.ordered_by('most_followed').map(&:name)).
        to eql(%w(great cookbook))
    end

    it 'orders secondarily by id when download counts are equal' do
      great.update_attributes(web_download_count: 5, api_download_count: 100)
      cookbook.update_attributes(web_download_count: 5, api_download_count: 100)

      expect(Cookbook.ordered_by('most_followed').map(&:name)).
        to eql(%w(great cookbook))
    end
  end

  describe '.owned_by' do
    let!(:hank) { create(:user) }
    let!(:tasty) { create(:cookbook, owner: hank) }

    it 'finds cookbooks owned by a username' do
      expect(Cookbook.owned_by(hank.username).first).to eql(tasty)
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

      expect(scope).to include(cookbook)
      expect(scope).to include(mybook)
    end
  end

  describe '.featured' do
    let(:featured) { create(:cookbook, featured: true) }
    let(:unfeatured) { create(:cookbook, featured: false) }

    it 'only returns featured cookbooks' do
      expect(Cookbook.featured).to include(featured)
      expect(Cookbook.featured).to_not include(unfeatured)
    end
  end

  describe '#followed_by?' do
    it 'returns true if the user passed follows the cookbook' do
      user = create(:user)
      cookbook = create(:cookbook)
      create(:cookbook_follower, user: user, cookbook: cookbook)

      expect(cookbook.followed_by?(user)).to be true
    end

    it "returns false if the user passed doesn't follow the cookbook" do
      user = create(:user)
      cookbook = create(:cookbook)

      expect(cookbook.followed_by?(user)).to be false
    end
  end

  describe '#download_count' do
    it 'is the sum of web_download_count and api_download_count' do
      cookbook = Cookbook.new(web_download_count: 1, api_download_count: 10)

      expect(cookbook.download_count).to eql(11)
    end
  end

  describe '.total_download_count' do
    it 'is the total number of downloads across all cookbooks' do
      2.times do
        create(:cookbook, web_download_count: 10, api_download_count: 100)
      end

      expect(Cookbook.total_download_count).to eql(220)
    end
  end
end
