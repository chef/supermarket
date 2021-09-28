require "spec_helper"

describe ApplicationHelper do
  describe "#auth_path" do
    context "when using a symbol" do
      it "returns the correct path" do
        expect(auth_path(:github)).to eq("/auth/github")
      end
    end

    context "when using a string" do
      it "returns the correct path" do
        expect(auth_path("github")).to eq("/auth/github")
      end
    end
  end

  describe "#posessivize" do
    it "should end in 's if the name does not end in s" do
      expect(posessivize("Black")).to eql "Black's"
    end

    it "should end in ' if the name ends in s" do
      expect(posessivize("Volkens")).to eql "Volkens'"
    end

    it "should return an empty string when passed one" do
      expect(posessivize("")).to eql ""
    end

    it "should return nil when passed nil" do
      expect(posessivize(nil)).to be_nil
    end
  end

  describe "#flash_message_class_for" do
    it "should return a flass message class for notice flash messages" do
      expect(flash_message_class_for("notice")).to eql("success")
    end

    it "should return a flass message class for alert flash messages" do
      expect(flash_message_class_for("alert")).to eql("alert")
    end

    it "should return a flass message class for warning flash messages" do
      expect(flash_message_class_for("warning")).to eql("warning")
    end
  end

  describe "#github_profile_url" do
    ENV["GITHUB_ENTERPRISE_URL"] = "https://example.com"
    it "should return a user's profile url" do
      expect(github_profile_url("johndoe")).to eql("https://example.com/johndoe")
    end
  end

  describe "#github_profile_title" do
    it "should return a user's github profile title" do
      expect(github_profile_title("John Doe's")).to eql("John Doe's GitHub Enterprise Username")
    end
  end
end
