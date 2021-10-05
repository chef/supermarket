require "spec_helper"

describe Cookbook do
  context "associations" do
    it { should have_many(:cookbook_versions) }
    it { should have_many(:cookbook_followers) }
    it { should have_many(:followers) }
    it { should belong_to(:category).optional }
    it { should belong_to(:owner) }
    it { should have_many(:collaborators) }
    it { should have_many(:collaborator_users) }
    it { should have_many(:direct_collaborators) }
    it { should have_many(:direct_collaborator_users) }
    it { should have_one(:chef_account) }
    it { should have_many(:group_resources) }
    it { should belong_to(:replacement).optional }
    it { should have_many(:replaces) }

    context "dependent deletions" do
      let!(:cookbook) { create(:cookbook) }
      let!(:follower) { create(:cookbook_follower, cookbook: cookbook, user: create(:user)) }
      let!(:collaborator) { create(:cookbook_collaborator, resourceable: cookbook, user: create(:user)) }

      before do
        cookbook.reload
      end

      it "should not destroy followers when deleted" do
        expect(cookbook.cookbook_followers.size).to eql(1)
        cookbook.destroy
        expect { follower.reload }.to_not raise_error
      end

      it "should not destroy collaborators when deleted" do
        expect(cookbook.collaborators.size).to eql(1)
        cookbook.destroy
        expect { collaborator.reload }.to_not raise_error
      end

      it "should not destroy cookbooks that have been deprecated in favor of a cookbook" do
        some_crusty_old_cookbook = create(:cookbook)
        some_crusty_old_cookbook.deprecate(cookbook.name)
        expect(some_crusty_old_cookbook.replacement).to eq(cookbook)
        cookbook.destroy
        expect { some_crusty_old_cookbook.reload }.to_not raise_error
        expect(some_crusty_old_cookbook.replacement).to be_nil
      end
    end
  end

  it_behaves_like "a badgeable thing"

  context "ordering versions" do
    let(:toast) { create(:cookbook) }

    before do
      toast.cookbook_versions.each(&:destroy)
      create(:cookbook_version, cookbook: toast, version: "0.1.0")
      create(:cookbook_version, cookbook: toast, version: "10.0.0")
      create(:cookbook_version, cookbook: toast, version: "9.9.9")
      create(:cookbook_version, cookbook: toast, version: "9.10.0")
      create(:cookbook_version, cookbook: toast, version: "0.2.0")
      toast.reload
    end

    it "should order versions based on the version number" do
      versions = toast.sorted_cookbook_versions.map(&:version)
      expect(toast.cookbook_versions.size).to eql(5)
      expect(versions).to eql(["10.0.0", "9.10.0", "9.9.9", "0.2.0", "0.1.0"])
    end

    it "should use the one with the largest version number for #latest_cookbook_version" do
      expect(toast.latest_cookbook_version.version).to eql("10.0.0")
    end
  end

  context "validations" do
    it "validates the uniqueness of name" do
      create(:cookbook)

      expect(subject).to validate_uniqueness_of(:name).case_insensitive
    end

    it "validates that issues_url is a http(s) url" do
      cookbook = create(:cookbook)
      create(:cookbook_version, cookbook: cookbook)
      cookbook.issues_url = "com.http.com"

      expect(cookbook).to_not be_valid
      expect(cookbook.errors[:issues_url]).to_not be_nil
    end

    it "validates that source_url is a http(s) url" do
      cookbook = create(:cookbook)
      create(:cookbook_version, cookbook: cookbook)
      cookbook.source_url = "com.http.com"

      expect(cookbook).to_not be_valid
      expect(cookbook.errors[:source_url]).to_not be_nil
    end

    it "does not allow spaces in cookbook names" do
      cookbook = Cookbook.new(name: "great cookbook")
      cookbook.valid?

      expect(cookbook.errors[:name]).to_not be_empty

      cookbook = Cookbook.new(name: "great-cookbook")
      cookbook.valid?

      expect(cookbook.errors[:name]).to be_empty
    end

    it "allows letters, numbers, dashes, and underscores in cookbook names" do
      cookbook = Cookbook.new(name: "Cookbook_-1")
      cookbook.valid?

      expect(cookbook.errors[:name]).to be_empty
    end

    it "allows deprecated cookbooks to optionally specify a replacement" do
      cookbook = Cookbook.new(deprecated: true)
      cookbook.valid?

      expect(cookbook.errors[:replacement]).to be_empty

      cookbook.replacement = Cookbook.new
      cookbook.valid?

      expect(cookbook.errors[:replacement]).to be_empty
    end

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:cookbook_versions) }
  end

  describe "#lowercase_name" do
    it "is set as part of the saving lifecycle" do
      cookbook = Cookbook.new(name: "Apache")

      expect do
        cookbook.save
      end.to change(cookbook, :lowercase_name).from(nil).to("apache")
    end
  end

  describe "#transfer_ownership" do
    let(:jimmy) { create(:user) }
    let(:cookbook) { create(:cookbook, owner: jimmy) }

    context "initiator is an admin" do
      let(:hank) { create(:user) }
      let(:sally) { create(:admin) }

      it "should instantly transfer ownership if the initiator is an admin" do
        result = cookbook.transfer_ownership(sally, hank)
        cookbook.reload
        expect(cookbook.owner).to eql(hank)
        expect(result).to eql("cookbook.ownership_transfer.done")
      end

      context "admin is not the owner" do
        it "keeps the owner as a collaborator" do
          cookbook.transfer_ownership(sally, hank, true)
          cookbook.reload
          collaborators_users = cookbook.collaborators.map(&:user)
          expect(collaborators_users).to include(jimmy)
        end
      end
    end

    it "should instantly transfer ownership if the recipient is a collaborator" do
      hank = create(:user)
      create(:cookbook_collaborator, resourceable: cookbook, user: hank)
      expect(cookbook.owner).to eql(jimmy)
      result = cookbook.transfer_ownership(jimmy, hank)
      cookbook.reload
      expect(cookbook.owner).to eql(hank)
      expect(result).to eql("cookbook.ownership_transfer.done")
    end

    context "removing the collaborator record" do
      let!(:hank) { create(:user) }
      let!(:cookbook_collaborator) { create(:cookbook_collaborator, resourceable: cookbook, user: hank) }

      before do
        expect(cookbook.owner).to eql(jimmy)
        expect(cookbook.collaborator_users).to include(hank)
      end

      context "when the collaborator is NOT part of a group" do
        it "should remove the collaborator record if the new owner used to be a collaborator" do
          cookbook.transfer_ownership(jimmy, hank)
          cookbook.reload
          expect(cookbook.owner).to eql(hank)
          expect(cookbook.collaborator_users).to_not include(hank)
        end
      end

      context "when the collaborator IS part of a group" do
        let!(:group) { create(:group) }

        before do
          cookbook_collaborator.group_id = group.id
          cookbook_collaborator.save!
        end

        it "does not remove the collaborator" do
          cookbook.transfer_ownership(jimmy, hank)
          cookbook.reload
          expect(cookbook.owner).to eql(hank)
          expect(cookbook.collaborator_users).to include(hank)
        end
      end
    end

    context "adding current owner as collaborator checkbox is selected" do
      it "should list the current owner as a collaborator" do
        hank = create(:user)
        create(:cookbook_collaborator, resourceable: cookbook, user: hank)
        expect(cookbook.owner).to eql(jimmy)
        expect(cookbook.collaborator_users).to_not include(jimmy)
        cookbook.transfer_ownership(jimmy, hank, true)
        cookbook.reload
        expect(cookbook.owner).to eql(hank)
        expect(cookbook.collaborator_users).to include(jimmy)
        expect(cookbook.collaborators.count).to eql(1)
      end
    end

    context "adding current owner as collaborator checkbox is not selected" do
      it "should not list the current owner as a collaborator" do
        hank = create(:user)
        create(:cookbook_collaborator, resourceable: cookbook, user: hank)
        expect(cookbook.owner).to eql(jimmy)
        cookbook.transfer_ownership(jimmy, hank, false)
        cookbook.reload
        expect(cookbook.owner).to eql(hank)
        expect(cookbook.collaborator_users).to_not include(jimmy)
        expect(cookbook.collaborators.count).to eql(0)
      end
    end

    it "should create a transfer request if the initiator is not an admin and the recipient is not a collaborator" do
      result = nil
      hank = create(:user)
      expect(cookbook.owner).to eql(jimmy)
      expect do
        result = cookbook.transfer_ownership(jimmy, hank)
        cookbook.reload
        expect(cookbook.owner).to eql(jimmy)
      end.to change(OwnershipTransferRequest, :count).by(1)
      expect(result).to eql("cookbook.ownership_transfer.email_sent")
    end

    it "should send an email to the recipient if the initiator is not an admin and the recipient is not a collaborator" do
      result = nil
      hank = create(:user)
      expect(cookbook.owner).to eql(jimmy)
      expect do
        Sidekiq::Testing.inline! do
          result = cookbook.transfer_ownership(jimmy, hank)
        end
      end.to change(ActionMailer::Base.deliveries, :size).by(1)
      expect(result).to eql("cookbook.ownership_transfer.email_sent")
    end
  end

  describe "#contingents" do
    let(:apt) { create(:cookbook, name: "apt") }
    let(:nginx) { create(:cookbook, name: "nginx") }
    let(:apache) { create(:cookbook, name: "apache") }

    before do
      create(:cookbook_dependency, cookbook: apt, cookbook_version: nginx.latest_cookbook_version)
      create(:cookbook_dependency, cookbook: apt, cookbook_version: apache.latest_cookbook_version)
    end

    it "knows which cookbooks are contingent upon this one" do
      cookbooks = apt.contingents.map { |c| c.cookbook_version.cookbook }
      expect(cookbooks).to eql([apache, nginx])
    end
  end

  describe "#to_param" do
    it "returns the cookbook's name downcased and parameterized" do
      cookbook = Cookbook.new(name: "Spicy Curry")
      expect(cookbook.to_param).to eql("spicy-curry")
    end
  end

  describe "#deprecate" do
    let!(:cookbook) { create(:cookbook, name: "spicy_curry") }

    context "with no replacement cookbook" do
      it "returns true" do
        result = cookbook.deprecate
        expect(result).to eql(true)
      end

      it "sets the deprecated attribute to true" do
        cookbook.deprecate

        expect(cookbook.deprecated?).to eql(true)
      end

      it "does not set a replacement" do
        cookbook.deprecate

        expect(cookbook.replacement).to eql(nil)
      end
    end

    context "replacement cookbook is valid" do
      let!(:replacement_cookbook) { create(:cookbook, name: "mild_curry") }

      it "returns true" do
        result = cookbook.deprecate(replacement_cookbook.name)
        expect(result).to eql(true)
      end

      it "sets the deprecated attribute to true" do
        cookbook.deprecate(replacement_cookbook.name)

        expect(cookbook.deprecated?).to eql(true)
      end

      it "sets the replacement" do
        cookbook.deprecate(replacement_cookbook.name)

        expect(cookbook.replacement).to eql(replacement_cookbook)
        expect(replacement_cookbook.replaces).to include(cookbook)
      end
    end

    context "replacement cookbook is deprecated" do
      let!(:replacement_cookbook) do
        create(
          :cookbook,
          name: "green_curry",
          deprecated: "true",
          replacement: create(:cookbook)
        )
      end

      it "returns false" do
        result = cookbook.deprecate(replacement_cookbook.name)
        expect(result).to eql(false)
      end

      it "fails to deprecate" do
        cookbook.deprecate(replacement_cookbook.name)

        expect(cookbook.deprecated?).to eql(false)
      end

      it "fails to set the replacement" do
        cookbook.deprecate(replacement_cookbook.name)

        expect(cookbook.replacement).to eql(nil)
      end

      it "adds an error if the replacement cookbook is deprecated" do
        expect do
          cookbook.deprecate(replacement_cookbook.name)
        end.to change(cookbook.errors, :count).by(1)
      end
    end
  end

  describe "#deprecate_search" do
    let!(:postgresql) { create(:cookbook, name: "postgresql") }
    let!(:postgres) { create(:cookbook, name: "postgres") }
    let!(:postgresql_lol) do
      create(
        :cookbook,
        name: "postgresql_lol",
        deprecated: "true",
        replacement: create(:cookbook)
      )
    end

    it "returns relevant cookbooks" do
      results = postgresql.deprecate_search("postgres")
      expect(results).to include(postgres)
    end

    it "does not return the cookbook being deprecated" do
      results = postgresql.deprecate_search("postgres")
      expect(results).to_not include(postgresql)
    end

    it "only returns non-deprecated cookbooks" do
      results = postgresql.deprecate_search("postgres")
      expect(results).to_not include(postgresql_lol)
    end
  end

  describe "#get_version!" do
    let!(:kiwi_0_1_0) do
      build(
        :cookbook_version,
        version: "0.1.0",
        license: "MIT"
      )
    end

    let!(:kiwi_0_2_0) do
      build(
        :cookbook_version,
        version: "0.2.0",
        license: "MIT"
      )
    end

    let!(:kiwi) do
      create(
        :cookbook,
        name: "kiwi",
        cookbook_versions_count: 0,
        cookbook_versions: [kiwi_0_2_0, kiwi_0_1_0]
      )
    end

    it "returns the cookbook version specified" do
      expect(kiwi.get_version!("0_1_0")).to eql(kiwi_0_1_0)
    end

    it "returns the cookbook version specified even if dots are used" do
      expect(kiwi.get_version!("0.1.0")).to eql(kiwi_0_1_0)
    end

    it "returns the highest version when the version is 'latest'" do
      expect(kiwi.get_version!("latest")).to eql(kiwi_0_2_0)
    end

    it "raises ActiveRecord::RecordNotFound if the version does not exist" do
      expect { kiwi.get_version!("0_4_0") }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#publish_version!" do
    let(:user) { create(:user) }
    def generate_params(opts = {})
      opts.reverse_merge!(
        source_url: "http://example.com",
        issues_url: "http://example.com/issues",
        version: "9.9.9"
      )

      tarball = build_cookbook_tarball("stuff") do |base|
        base.file("README.md") { "readme" }
        base.file("CHANGELOG.txt") { "changelog" }
        base.file("metadata.json") do
          JSON.dump(
            name: "stuff",
            license: "MIT",
            version: opts[:version],
            description: "Description",
            platforms: {
              "ubuntu" => "= 12.04",
              "debian" => ">= 0.0.0",
            },
            dependencies: {
              "apt" => "= 1.2.3",
              "yum" => "~> 2.1.3",
            },
            source_url: opts[:source_url],
            issues_url: opts[:issues_url]
          )
        end
      end

      CookbookUpload::Parameters.new(cookbook: "{}", tarball: tarball)
    end

    let(:cookbook) { create(:cookbook) }
    let(:params) { generate_params }

    it "creates supported platforms from the metadata" do
      cookbook.publish_version!(params, user)
      supported_platforms = cookbook.reload.supported_platforms

      expect(supported_platforms.map(&:name)).to match_array(%w{debian ubuntu})
      expect(supported_platforms.map(&:version_constraint))
        .to match_array(["= 12.04", ">= 0.0.0"])
    end

    it "creates cookbook dependencies from the metadata" do
      cookbook.publish_version!(params, user)

      dependencies = cookbook.reload.cookbook_dependencies

      expect(dependencies.map(&:name)).to match_array(%w{apt yum})
      expect(dependencies.map(&:version_constraint))
        .to match_array(["= 1.2.3", "~> 2.1.3"])
    end

    it "bumps the updated at date" do
      original_date = cookbook.updated_at
      cookbook.publish_version!(params, user)

      expect(cookbook.updated_at).to be > original_date
    end

    it "sets the source_url attribute on the cookbook" do
      cookbook.publish_version!(params, user)

      expect(cookbook.source_url).to eql("http://example.com")
    end

    it "sets the issues_url attribute on the cookbook" do
      cookbook.publish_version!(params, user)

      expect(cookbook.issues_url).to eql("http://example.com/issues")
    end

    it "does not erase source_url or issues_url after they have been set" do
      cookbook.publish_version!(params, user)
      expect(cookbook.source_url).to eql("http://example.com")
      expect(cookbook.issues_url).to eql("http://example.com/issues")

      new_params = generate_params(
        source_url: "",
        issues_url: "",
        version: "10.0.0"
      )

      cookbook.publish_version!(new_params, user)
      expect(cookbook.source_url).to eql("http://example.com")
      expect(cookbook.issues_url).to eql("http://example.com/issues")
    end

    it "saves the CHANGELOG" do
      cookbook.publish_version!(params, user)

      expect(cookbook.cookbook_versions.last.changelog).to eql("changelog")
      expect(cookbook.cookbook_versions.last.changelog_extension).to eql("txt")
    end

    it "returns the cookbook version" do
      cookbook_version = cookbook.publish_version!(params, user)

      expect(cookbook_version).to eql(cookbook.cookbook_versions.last)
    end

    context "setting chef versions and ohai versions" do
      def generate_params_versions(opts = {})
        opts.reverse_merge!(
          source_url: "http://example.com",
          issues_url: "http://example.com/issues",
          version: "9.9.9"
        )

        tarball = build_cookbook_tarball("stuff") do |base|
          base.file("README.md") { "readme" }
          base.file("CHANGELOG.txt") { "changelog" }
          base.file("metadata.json") do
            JSON.dump(
              name: "stuff",
              license: "MIT",
              version: opts[:version],
              description: "Description",
              platforms: {
                "ubuntu" => "= 12.04",
                "debian" => ">= 0.0.0",
              },
              dependencies: {
                "apt" => "= 1.2.3",
                "yum" => "~> 2.1.3",
              },
              source_url: opts[:source_url],
              issues_url: opts[:issues_url],
              chef_versions: [["12.4.1", "12.4.2"], ["11.2.3", "12.4.3"]],
              ohai_versions: [["8.8.1", "8.8.2"], ["8.9.1", "8.9.2"]]
            )
          end
        end

        CookbookUpload::Parameters.new(cookbook: "{}", tarball: tarball)
      end

      let(:cookbook) { create(:cookbook) }
      let(:params) { generate_params_versions }

      it "sets the chef_versions attribute on the cookbook version" do
        cookbook.publish_version!(params, user)

        expect(cookbook.cookbook_versions.last.chef_versions).to eq([["12.4.1", "12.4.2"], ["11.2.3", "12.4.3"]])
      end

      it "sets the ohai_versions attribute on the cookbook" do
        cookbook.publish_version!(params, user)

        expect(cookbook.cookbook_versions.last.ohai_versions).to eq([["8.8.1", "8.8.2"], ["8.9.1", "8.9.2"]])
      end
    end

    it "saves the README" do
      cookbook.publish_version!(params, user)

      expect(cookbook.cookbook_versions.last.readme).to eql("readme")
      expect(cookbook.cookbook_versions.last.readme_extension).to eql("md")
    end

    it "captures the uploading user id" do
      cookbook.publish_version!(params, user)

      expect(cookbook.cookbook_versions.last.user).to_not eql(nil)
    end
  end

  describe ".search" do
    let!(:redis) do
      create(
        :cookbook,
        name: "redis",
        category: create(:category, name: "datastore"),
        owner: create(:user, chef_account: create(:account, provider: "chef_oauth2", username: "johndoe"), create_chef_account: false),
        cookbook_versions: [
          build(
            :cookbook_version,
            description: "Redis: a fast, flexible datastore offering an extremely useful set of data structure primitives"
          ),
        ]
      )
    end

    let!(:redisio) do
      create(
        :cookbook,
        name: "redisio",
        category: create(:category, name: "datastore"),
        owner: create(:user, chef_account: create(:account, provider: "chef_oauth2", username: "fanny"), create_chef_account: false),
        cookbook_versions: [
          build(
            :cookbook_version,
            description: "Installs/Configures redis. Created by the formidable johndoe, johndoe is pretty awesome."
          ),
        ],
        cookbook_versions_count: 0
      )
    end

    it "returns cookbooks with a similar name" do
      expect(Cookbook.search("redis")).to include(redis)
      expect(Cookbook.search("redis")).to include(redisio)
    end

    it "returns cookbooks with a similar description" do
      expect(Cookbook.search("fast")).to include(redis)
      expect(Cookbook.search("fast")).to_not include(redisio)
    end

    it "returns cookbooks with a similar maintainer" do
      expect(Cookbook.search("johndoe")).to include(redisio)
      expect(Cookbook.search("janesmith")).to_not include(redisio)
    end

    it "weights cookbook name over cookbook description" do
      expect(Cookbook.search("redis")[0]).to eql(redis)
      expect(Cookbook.search("redis")[1]).to eql(redisio)
    end

    it "weights cookbook maintainer over cookbook description" do
      expect(Cookbook.search("johndoe")[0]).to eql(redis)
      expect(Cookbook.search("johndoe")[1]).to eql(redisio)
    end
  end

  describe ".filter_platforms" do
    let!(:debian_platform) do
      create(
        :supported_platform,
        name: "debian"
      )
    end

    let!(:erlang) do
      create(
        :cookbook,
        name: "erlang",
        cookbook_versions: [
          build(
            :cookbook_version,
            supported_platforms: [
              debian_platform,
              create(:supported_platform, name: "ubuntu"),
            ]
          ),
        ]
      )
    end

    let!(:ruby) do
      create(
        :cookbook,
        name: "ruby",
        cookbook_versions: [
          build(
            :cookbook_version,
            supported_platforms: [
              debian_platform,
              create(:supported_platform, name: "windows"),
            ]
          ),
        ]
      )
    end

    it "returns cookbooks that support some of given platforms" do
      expect(Cookbook.filter_platforms(["debian"])).to include(erlang)
      expect(Cookbook.filter_platforms(["debian"])).to include(ruby)
      expect(Cookbook.filter_platforms(%w{windows ubuntu})).to include(ruby)
      expect(Cookbook.filter_platforms(%w{windows ubuntu})).to include(erlang)
    end

    it "only returns cookbooks that support some of given platforms" do
      expect(Cookbook.filter_platforms("ubuntu")).to include(erlang)
      expect(Cookbook.filter_platforms("ubuntu")).to_not include(ruby)
    end
  end

  describe ".ordered_by" do
    let!(:great) { create(:cookbook, name: "great") }
    let!(:cookbook) { create(:cookbook, name: "cookbook") }
    let!(:deprecated_cookbook) { create(:cookbook, name: "deprecated_cookbook", deprecated: "true") }

    it "orders by name ascending by default" do
      expect(Cookbook.ordered_by(nil).map(&:name)).to eql(%w{cookbook great deprecated_cookbook})
    end

    it 'orders by updated_at descending when given "recently_updated"' do
      great.touch
      expect(Cookbook.ordered_by("recently_updated").map(&:name))
        .to eql(%w{great cookbook deprecated_cookbook})
    end

    it 'orders by created_at descending when given "recently_added"' do
      create(:cookbook, name: "neat")

      expect(Cookbook.ordered_by("recently_added").first.name).to eql("neat")
    end

    it 'orders by download_count descending when given "most_downloaded"' do
      great.update(web_download_count: 1, api_download_count: 100)
      cookbook.update(web_download_count: 5, api_download_count: 70)

      expect(Cookbook.ordered_by("most_downloaded").map(&:name))
        .to eql(%w{great cookbook deprecated_cookbook})
    end

    it 'orders by cookbook_followers_count when given "most_followed"' do
      great.update(cookbook_followers_count: 100)
      cookbook.update(cookbook_followers_count: 50)
      deprecated_cookbook.update( cookbook_followers_count: 50)

      expect(Cookbook.ordered_by("most_followed").map(&:name))
        .to eql(%w{great cookbook deprecated_cookbook})
    end

    it "orders secondarily by id when cookbook follower counts are equal" do
      great.update(cookbook_followers_count: 100)
      cookbook.update(cookbook_followers_count: 100)
      deprecated_cookbook.update(cookbook_followers_count: 100)

      expect(Cookbook.ordered_by("most_followed").map(&:name))
        .to eql(%w{great cookbook deprecated_cookbook})
    end

    it "orders secondarily by id when download counts are equal" do
      great.update(web_download_count: 5, api_download_count: 100)
      cookbook.update(web_download_count: 5, api_download_count: 100)
      deprecated_cookbook.update(web_download_count: 5, api_download_count: 100)

      expect(Cookbook.ordered_by("most_followed").map(&:name))
        .to eql(%w{great cookbook deprecated_cookbook})
    end
  end

  describe ".owned_by" do
    let!(:hank) { create(:user) }
    let!(:tasty) { create(:cookbook, owner: hank) }

    it "finds cookbooks owned by a username" do
      expect(Cookbook.owned_by(hank.username).first).to eql(tasty)
    end
  end

  describe ".with_name" do
    it "is case-insensitive" do
      cookbook = create(:cookbook, name: "CookBook")

      expect(Cookbook.with_name("Cookbook")).to include(cookbook)
    end

    it "can locate multiple cookbooks at once" do
      cookbook = create(:cookbook, name: "CookBook")
      mybook = create(:cookbook, name: "MYBook")

      scope = Cookbook.with_name(%w{Cookbook MyBook})

      expect(scope).to include(cookbook)
      expect(scope).to include(mybook)
    end
  end

  describe ".featured" do
    let(:featured) { create(:cookbook, featured: true) }
    let(:unfeatured) { create(:cookbook, featured: false) }

    it "only returns featured cookbooks" do
      expect(Cookbook.featured).to include(featured)
      expect(Cookbook.featured).to_not include(unfeatured)
    end
  end

  describe "#followed_by?" do
    it "returns true if the user passed follows the cookbook" do
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

  describe "#download_count" do
    it "is the sum of web_download_count and api_download_count" do
      cookbook = Cookbook.new(web_download_count: 1, api_download_count: 10)

      expect(cookbook.download_count).to eql(11)
    end
  end

  describe ".total_download_count" do
    it "is the total number of downloads across all cookbooks" do
      2.times do
        create(:cookbook, web_download_count: 10, api_download_count: 100)
      end

      expect(Cookbook.total_download_count).to eql(220)
    end
  end
end
