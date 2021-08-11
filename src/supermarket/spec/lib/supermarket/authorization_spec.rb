require "spec_helper"

class ReadOnly
  class Policy
    def initialize(*_); end

    def show?
      true
    end

    def edit?
      false
    end
  end

  def policy_class
    Policy
  end
end

describe Supermarket::Authorization do
  subject do
    Class.new(ApplicationController) do
      include Supermarket::Authorization
      def current_user; end
      # in latest new Pundit gem authorize is a protected method,
      # so we need to call it from an instace method

      def public_authorize(record, query = nil)
        authorize!(record, query)
      end

    end.new
  end

  let(:read_only_object) { ReadOnly.new }

  describe "#authorize!" do
    it "raises an error if the user is not authorized" do
      allow(subject).to receive(:action_name).and_return("edit")
      expect { subject.public_authorize(read_only_object).to raise_error(Supermarket::Authorization::NotAuthorizedError) }
    end

    it "does nothing with the user is authorized" do
      allow(subject).to receive(:action_name).and_return("show")
      expect { subject.public_authorize(read_only_object) }.to_not raise_error
    end
  end
end
