require 'spec_helper'

describe Api::V1::CookbookUploadsController do
  describe '#create' do
    context 'when the upload succeeds' do
      before do
        allow_any_instance_of(CookbookUpload).
          to receive(:finish).
          and_yield([], double('Cookbook'))
      end

      it 'sends the cookbook to the view' do
        post :create, cookbook: 'cookbook', tarball: 'tarball', format: :json

        expect(assigns[:cookbook]).to_not be_nil
      end

      it 'returns a 201' do
        post :create, cookbook: 'cookbook', tarball: 'tarball', format: :json

        expect(response.status.to_i).to eql(201)
      end
    end

    context 'when the upload fails' do
      before do
        errors = ActiveModel::Errors.new([]).tap do |e|
          e.add(:base, 'This cookbook is no good')
        end

        allow_any_instance_of(CookbookUpload).
          to receive(:finish).
          and_yield(errors, double('Cookbook'))
      end

      it 'renders the error messages' do
        post :create, cookbook: 'cookbook', tarball: 'tarball', format: :json

        expect(JSON.parse(response.body)).to eql(
          'error' => I18n.t('api.error_codes.invalid_data'),
          'error_messages' => ['This cookbook is no good']
        )
      end

      it 'returns a 400' do
        post :create, cookbook: 'cookbook', tarball: 'tarball', format: :json

        expect(response.status.to_i).to eql(400)
      end
    end

    context 'when the tarball parameter is missing' do
      it 'returns a 400' do
        post :create, cookbook: '{}', format: :json

        expect(response.status.to_i).to eql(400)
      end
    end

    context 'when the cookbook parameter is missing' do
      it 'returns a 400' do
        post :create, tarball: 'tarball', format: :json

        expect(response.status.to_i).to eql(400)
      end
    end
  end
end
