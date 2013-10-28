require 'spec_helper'

describe IclaSignaturesController do
  describe 'GET #index' do
    before { get :index }

    it { should respond_with(200) }
    it { should render_template('index') }

    it 'assigns @icla_signatures' do
      signatures = create_list(:icla_signature, 2)
      expect(assigns(:icla_signatures)).to eq(signatures)
    end
  end

  describe 'GET #show' do
    let(:icla_signature) { create(:icla_signature) }
    before { get :show, id: icla_signature.id }

    it { should respond_with(200) }
    it { should render_template('show') }

    it 'assigns @icla_signature' do
      expect(assigns(:icla_signature)).to eq(icla_signature)
    end
  end
end
