require "spec_helper"

describe Api::V1::CookbookUploadsController do
  describe "#create" do
    context "when the upload succeeds" do
      let(:user) { create(:user) }
      before do
        allow(subject).to receive(:authenticate_user!) { true }
        allow(subject).to receive(:current_user) { user }

        allow_any_instance_of(CookbookUpload)
          .to receive(:finish)
          .and_yield(
            [],
            double("Cookbook", name: "cookbook", id: 1),
            double("CookbookVersion", version: "1.1.1", id: 1, cookbook_id: 1)
          )
        auto_authorize!(Cookbook, "create")
      end

      it "passes current_user to CookbookUpload#finish" do
        expect_any_instance_of(CookbookUpload).to receive(:finish)
        post :create, params: { cookbook: "cookbook", tarball: "tarball", format: :json }
      end

      it "sends the cookbook to the view" do
        post :create, params: { cookbook: "cookbook", tarball: "tarball", format: :json }

        expect(assigns[:cookbook]).to_not be_nil
      end

      it "returns a 201" do
        post :create, params: { cookbook: "cookbook", tarball: "tarball", format: :json }

        expect(response.status.to_i).to eql(201)
      end

      it "kicks off a CookbookNotifyWorker" do
        expect do
          post :create, params: { cookbook: "cookbook", tarball: "tarball", format: :json }
        end.to change(CookbookNotifyWorker.jobs, :size).by(1)
      end

      it "kicks off a FieriNotifyWorker" do
        expect do
          post :create, params: { cookbook: "cookbook", tarball: "tarball", format: :json }
        end.to change(FieriNotifyWorker.jobs, :size).by(1)
      end

      it "kicks off spdx license upate worker" do
        expect do
          post :create, params: { cookbook: "cookbook", tarball: "tarball", format: :json }
        end.to change(SpdxLicenseUpdateWorker.jobs, :size).by(1)
      end

      it "regenerates the universe cache" do
        expect(UniverseCache).to receive(:flush)
        post :create, params: { cookbook: "cookbook", tarball: "tarball", format: :json }
      end
    end

    context "when the upload fails" do
      before do
        allow(subject).to receive(:authenticate_user!) { true }
        allow(subject).to receive(:current_user) { create(:user) }

        errors = ActiveModel::Errors.new([]).tap do |e|
          e.add(:base, "This cookbook is no good")
        end

        allow_any_instance_of(CookbookUpload)
          .to receive(:finish)
          .and_yield(errors, double("Cookbook"), double("CookbookVersion"))
        auto_authorize!(Cookbook, "create")
      end

      it "renders the error messages" do
        post :create, params: { cookbook: "cookbook", tarball: "tarball", format: :json }

        expect(JSON.parse(response.body)).to eql(
          "error_code" => I18n.t("api.error_codes.invalid_data"),
          "error_messages" => ["This cookbook is no good"]
        )
      end

      it "returns a 400" do
        post :create, params: { cookbook: "cookbook", tarball: "tarball", format: :json }

        expect(response.status.to_i).to eql(400)
      end
    end

    context "when the user is not authorized to upload an existing cookbook" do
      before do
        allow(subject).to receive(:authenticate_user!) { true }
        allow(subject).to receive(:current_user) { create(:user) }
      end

      it "renders an error informing the the user that they may not modify the cookbook" do
        post :create, params: { cookbook: "not valid data because", tarball: "this upload should not even be processed", format: :json }

        expect(JSON.parse(response.body)).to eql(
          "error_code" => I18n.t("api.error_codes.unauthorized"),
          "error_messages" => [I18n.t("api.error_messages.unauthorized_upload_error")]
        )
      end

      it "returns a 401" do
        post :create, params: { cookbook: "not valid data because", tarball: "this upload should not even be processed", format: :json }

        expect(response.status.to_i).to eql(401)
      end
    end

    context "when the tarball parameter is missing" do
      it "returns a 400" do
        post :create, params: { cookbook: "{}", format: :json }

        expect(response.status.to_i).to eql(400)
      end
    end

    context "when the cookbook parameter is missing" do
      it "returns a 400" do
        post :create, params: { tarball: "tarball", format: :json }

        expect(response.status.to_i).to eql(400)
      end
    end
  end

  describe "#destroy" do
    let(:user) { create(:user) }

    before do
      allow(subject).to receive(:authenticate_user!) { true }
      allow(subject).to receive(:current_user) { user }
    end

    shared_examples "authorized to destroy cookbook" do
      it "sends the cookbook to the view" do
        unshare
        expect(assigns[:cookbook]).to eql(cookbook)
      end

      it "responds with a 200" do
        unshare
        expect(response.status.to_i).to eql(200)
      end

      it "destroys a cookbook" do
        expect { unshare }.to change(Cookbook, :count).by(-1)
      end

      it "destroys all associated cookbook versions" do
        expect { unshare }.to change(CookbookVersion, :count).by(-2)
      end

      it "kicks off a deletion process in a worker" do
        expect(CookbookDeletionWorker).to receive(:perform_async)
        unshare
      end

      it "regenerates the universe cache" do
        expect(UniverseCache).to receive(:flush)
        unshare
      end
    end

    shared_examples "not authorized to destroy cookbook" do
      it "sends the cookbook to the view" do
        unshare
        expect(assigns[:cookbook]).to eql(cookbook)
      end

      it "responds with unauthorized" do
        unshare
        expect(response.status.to_i).to eql(403)
      end

      it "does not destroy a cookbook" do
        expect { unshare }.not_to change(Cookbook, :count)
      end

      it "does not destroy all associated cookbook versions" do
        expect { unshare }.not_to change(CookbookVersion, :count)
      end

      it "does not kick off a deletion process in a worker" do
        expect(CookbookDeletionWorker).not_to receive(:perform_async)
        unshare
      end

      it "does not regenerate the universe cache" do
        expect(UniverseCache).not_to receive(:flush)
        unshare
      end
    end

    context "when a cookbook exists" do
      context "and the current user is the owner" do
        let!(:cookbook) { create(:cookbook, owner: user) }
        let(:unshare) { delete :destroy, params: { cookbook: cookbook.name, format: :json } }
        context "and owners are allowed to remove cookbooks" do
          before do
            allow(ENV).to receive(:[]).with("OWNERS_CAN_REMOVE_ARTIFACTS").and_return("true")
          end

          it_behaves_like "authorized to destroy cookbook"
        end

        context "and owners are not allowed to remove cookbooks" do
          before do
            allow(ENV).to receive(:[]).with("OWNERS_CAN_REMOVE_ARTIFACTS").and_return("false")
          end

          it_behaves_like "not authorized to destroy cookbook"
        end
      end

      context "and the current user is an admin" do
        let(:user) { create(:admin) }
        let!(:cookbook) { create(:cookbook) }
        let(:unshare) { delete :destroy, params: { cookbook: cookbook.name, format: :json } }

        context "and owners are allowed to remove cookbooks" do
          before do
            allow(ENV).to receive(:[]).with("OWNERS_CAN_REMOVE_ARTIFACTS").and_return("true")
          end

          it_behaves_like "authorized to destroy cookbook"
        end

        context "and owners are not allowed to remove cookbooks" do
          before do
            allow(ENV).to receive(:[]).with("OWNERS_CAN_REMOVE_ARTIFACTS").and_return("false")
          end

          it_behaves_like "authorized to destroy cookbook"
        end
      end
    end

    context "when the user is not authorized to destroy the cookbook" do
      let!(:cookbook) { create(:cookbook) }
      let(:unshare) { delete :destroy, params: { cookbook: cookbook.name, format: :json } }

      it "returns a 403" do
        unshare

        expect(response.status.to_i).to eql(403)
      end
    end

    context "when a cookbook does not exist" do
      it "responds with a 404" do
        delete :destroy, params: { cookbook: "mamimi", format: :json }

        expect(response.status.to_i).to eql(404)
      end
    end
  end

  describe "#destroy_version" do
    before do
      allow(subject).to receive(:authenticate_user!) { true }
      allow(subject).to receive(:current_user) { create(:user) }
    end

    let!(:cookbook) { create(:cookbook) }
    let!(:cookbook_version) { create(:cookbook_version, cookbook: cookbook) }
    let(:unshare_version) do
      delete(:destroy_version, params: { cookbook: cookbook.name, version: cookbook_version.version, format: :json })
    end

    context "when a cookbook and cookbook version exists" do
      before { auto_authorize!(Cookbook, "destroy") }

      it "sends the cookbook to the view" do
        unshare_version
        expect(assigns[:cookbook]).to eql(cookbook)
      end

      it "sends the cookbook version to the view" do
        unshare_version
        expect(assigns[:cookbook_version]).to eql(cookbook_version)
      end

      it "responds with a 200" do
        unshare_version
        expect(response.status.to_i).to eql(200)
      end

      it "destroys a cookbook version" do
        expect { unshare_version }.to change(CookbookVersion, :count).by(-1)
      end

      it "regenerates the universe cache" do
        expect(UniverseCache).to receive(:flush)
        unshare_version
      end
    end

    context "when the user is not authorized to destroy the cookbook veresion" do
      it "returns a 403" do
        unshare_version

        expect(response.status.to_i).to eql(403)
      end
    end

    context "when there is only one version of the cookbook remaining" do
      before { auto_authorize!(Cookbook, "destroy") }

      it "returns a 409 with informative error messages" do
        versions = CookbookVersion.all.pluck(:version)
        versions.each do |version|
          delete :destroy_version, params: { cookbook: cookbook, version: version, format: :json }
        end

        expect(response.status.to_i).to eql(409)
        expect(JSON.parse(response.body)["error"]).to eq(I18n.t("api.error_messages.only_cookbook_version"))
      end
    end

    context "when a cookbook does not exist" do
      it "responds with a 404" do
        delete :destroy_version, params: { cookbook: "mamimi", version: "1.0.0", format: :json }

        expect(response.status.to_i).to eql(404)
      end
    end

    context "when a cookbook version does not exist" do
      it "responds with a 404" do
        delete :destroy_version, params: { cookbook: cookbook, version: "1.0.0", format: :json }

        expect(response.status.to_i).to eql(404)
      end
    end
  end
end
