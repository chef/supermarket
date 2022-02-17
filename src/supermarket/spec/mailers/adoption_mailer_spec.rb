require "spec_helper"

describe AdoptionMailer do
  describe "interest_email" do
    let(:cookbook) { create(:cookbook) }
    let(:user) { create(:user) }

    subject do
      AdoptionMailer.interest_email(cookbook.id, cookbook.class.name, user.id)
    end

    context "in the to address" do
      it "includes the current owner's email" do
        expect(subject.to).to include(cookbook.owner.email)
      end
    end

    context "in the subject" do
      it "includes the correct name" do
        expect(subject.subject).to include(cookbook.name)
      end

      it "includes the type of cookbook or tool" do
        expect(subject.subject).to include(cookbook.class.name.downcase)
      end
    end

    context "in the body" do
      it "includes the adopting user email" do
        expect(subject.text_part.to_s).to include(user.email)
        expect(subject.html_part.to_s).to include(user.email)
      end

      it "includes the username of the adopting user" do
        expect(subject.text_part.to_s).to include(user.username)
        expect(subject.html_part.to_s).to include(user.username)
      end

      it "includes the type of cookbook or tool" do
        expect(subject.text_part.to_s).to include(cookbook.class.name.downcase)
        expect(subject.html_part.to_s).to include(cookbook.class.name.downcase)
      end

      it "includes the name of the cookbook" do
        expect(subject.text_part.to_s).to include(cookbook.name)
        expect(subject.html_part.to_s).to include(cookbook.name)
      end

      context "including a link to the cookbook page" do
        it "includes the supermarket url" do
          expect(subject.text_part.to_s).to include(root_url)
          expect(subject.html_part.to_s).to include(root_url)
        end

        it "includes a link to the cookbook page" do
          expect(subject.text_part.to_s).to include(cookbook_url(cookbook))
          expect(subject.html_part.to_s).to include(cookbook_url(cookbook))
        end
      end
    end
  end
end
