module Authorizers
  class IclaSignaturePolicy
    include Authorizer

    #
    # * Everyone can view the full list of ICLA signatures.
    #
    def index?
      true
    end

    #
    # * Admins, API, Employees, and Legal can view all ICLA signatures.
    # * Users can view their own ICLA signature.
    #
    def show?
      if user.is?(:admin, :api, :employee, :legal)
        true
      else
        record.user_id == user.id
      end
    end

    #
    # * Admins and Legal can create ICLA signatures.
    # * Users can create their own ICLA signature.
    #
    def create?
      if user.is?(:admin, :legal)
        true
      else
        record.user_id == user.id
      end
    end

    #
    # @see create?
    #
    def new?
      create?
    end

    #
    # * Admins and Legal can update ICLA signatures.
    #
    def update?
      user.is?(:admin, :legal)
    end

    #
    # @see update?
    #
    def edit?
      update?
    end

    #
    # * Admins and Legal can delete ICLA signatures.
    #
    def destroy?
      user.is?(:admin, :legal)
    end
  end
end
