require 'spec_helper'

describe UsersHelper do
  describe '#gravatar_for' do
    it "returns the image tag for the specified user's gravtar image" do
      user = create(:user, email: 'johndoe@example.com')
      expect(gravatar_for(user)).to eq('<img alt="John Doe" class="gravatar" src="https://secure.gravatar.com/avatar/fd876f8cd6a58277fc664d47ea10ad19?s=48" />')
    end

    it "returns the image tag for the specified user's gravtar image with size" do
      user = create(:user, email: 'johndoe@example.com')
      expect(gravatar_for(user, size: 128)).to eq('<img alt="John Doe" class="gravatar" src="https://secure.gravatar.com/avatar/fd876f8cd6a58277fc664d47ea10ad19?s=128" />')
    end
  end
end
