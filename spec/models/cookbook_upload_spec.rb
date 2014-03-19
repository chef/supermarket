require 'spec_helper'

describe CookbookUpload do
  describe '#finish' do
    before do
      create(:category, name: 'Other')
    end

    let(:cookbook) do
      JSON.dump('category' => 'Other')
    end

    it 'creates a new cookbook if the given name is original' do
      tarball = File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz')

      upload = CookbookUpload.new(cookbook: cookbook, tarball: tarball)

      expect do
        upload.finish
      end.to change(Cookbook, :count).by(1)
    end

    it 'updates the existing cookbook if the given name is a duplicate' do
      tarball_one = File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz')
      tarball_two = File.open('spec/support/cookbook_fixtures/redis-test-v2.tgz')

      CookbookUpload.new(cookbook: cookbook, tarball: tarball_one).finish

      update = CookbookUpload.new(cookbook: cookbook, tarball: tarball_two)

      expect do
        update.finish
      end.to_not change(Cookbook, :count)
    end

    it 'creates a new version of the cookbook if the given name is a duplicate' do
      tarball_one = File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz')
      tarball_two = File.open('spec/support/cookbook_fixtures/redis-test-v2.tgz')

      cookbook_record = CookbookUpload.new(
        cookbook: cookbook,
        tarball: tarball_one
      ).finish do |_, result|
        result
      end

      update = CookbookUpload.new(cookbook: cookbook, tarball: tarball_two)

      expect do
        update.finish
      end.to change(cookbook_record.cookbook_versions, :count).by(1)
    end

    it 'yields empty errors if the cookbook and tarball are workable' do
      tarball = File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz')

      upload = CookbookUpload.new(cookbook: cookbook, tarball: tarball)
      errors = upload.finish { |e, _| e }

      expect(errors).to be_empty
    end

    it 'yields an error if the cookbook is not valid JSON' do
      upload = CookbookUpload.new(cookbook: 'ack!', tarball: 'tarball')
      errors = upload.finish { |e, _| e }

      expect(errors.full_messages).
        to include(I18n.t('api.error_messages.cookbook_not_json'))
    end

    it 'yields an error if the tarball does not seem to be an uploaded File' do
      upload = CookbookUpload.new(cookbook: '{}', tarball: 'cool')
      errors = upload.finish { |e, _| e }

      expect(errors.full_messages).
        to include(I18n.t('api.error_messages.tarball_has_no_path'))
    end

    it 'yields an error if the tarball is not GZipped' do
      tarball = File.open('spec/support/cookbook_fixtures/not-actually-gzipped.tgz')

      upload = CookbookUpload.new(cookbook: '{}', tarball: tarball)
      errors = upload.finish { |e, _| e }

      expect(errors.full_messages).
        to include(I18n.t('api.error_messages.tarball_not_gzipped'))
    end

    it 'yields an error if the tarball has no metadata.json entry' do
      tarball = File.open('spec/support/cookbook_fixtures/no-metadata-or-readme.tgz')

      upload = CookbookUpload.new(cookbook: '{}', tarball: tarball)
      errors = upload.finish { |e, _| e }

      expect(errors.full_messages).
        to include(I18n.t('api.error_messages.missing_metadata'))
    end

    it 'yields an error if the tarball has no README entry' do
      tarball = File.open('spec/support/cookbook_fixtures/no-metadata-or-readme.tgz')

      upload = CookbookUpload.new(cookbook: '{}', tarball: tarball)
      errors = upload.finish { |e, _| e }

      expect(errors.full_messages).
        to include(I18n.t('api.error_messages.missing_readme'))
    end

    it "yields an error if the tarball's metadata.json is not actually JSON" do
      tarball = File.open('spec/support/cookbook_fixtures/invalid-metadata-json.tgz')

      upload = CookbookUpload.new(cookbook: '{}', tarball: tarball)
      errors = upload.finish { |e, _| e }

      expect(errors.full_messages).
        to include(I18n.t('api.error_messages.metadata_not_json'))
    end

    it 'yields an error if the cookbook parameters do not specify a category' do
      tarball = File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz')

      upload = CookbookUpload.new(cookbook: '{}', tarball: tarball)
      errors = upload.finish { |e, _| e }

      error_message = I18n.t(
        'api.error_messages.non_existent_category',
        category_name: ''
      )

      expect(errors.full_messages).to include(error_message)
    end

    it 'yields an error if the cookbook parameters specify an invalid category' do
      tarball = File.open('spec/support/cookbook_fixtures/redis-test-v1.tgz')

      upload = CookbookUpload.new(
        cookbook: '{"category": "Kewl"}',
        tarball: tarball
      )
      errors = upload.finish { |e, _| e }

      error_message = I18n.t(
        'api.error_messages.non_existent_category',
        category_name: 'Kewl'
      )

      expect(errors.full_messages).to include(error_message)
    end
  end
end
