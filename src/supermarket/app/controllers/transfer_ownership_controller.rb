class TransferOwnershipController < ApplicationController
  before_action :find_transfer_request, only: [:accept, :decline]

  #
  # PUT /cookbooks/:id/transfer_ownership
  #
  # Attempts to transfer ownership of cookbook to another user and redirects
  # back to the cookbook.
  #
  def transfer
    @cookbook = Cookbook.with_name(params[:id]).first!
    authorize! @cookbook, :transfer_ownership?
    recipient = User.find(transfer_ownership_params[:user_id])

    msg = @cookbook.transfer_ownership(current_user, recipient, add_owner_as_collaborator?)
    redirect_to cookbook_path(@cookbook), notice: t(msg, cookbook: @cookbook.name, user: recipient.username)
  end

  #
  # GET /ownership_transfer/:token/accept
  #
  # Accepts an OwnershipTransferRequest and redirects back to the cookbook.
  #
  def accept
    @transfer_request.accept!
    redirect_to @transfer_request.cookbook,
                notice: t(
                  "cookbook.ownership_transfer.invite_accepted",
                  cookbook: @transfer_request.cookbook.name
                )
  end

  #
  # GET /ownership_transfer/:token/decline
  #
  # Declines an OwnershipTransferRequest and redirects back to the cookbook.
  #
  def decline
    @transfer_request.decline!
    redirect_to @transfer_request.cookbook,
                notice: t(
                  "cookbook.ownership_transfer.invite_declined",
                  cookbook: @transfer_request.cookbook.name
                )
  end

  private

  #
  # Finds an OwnershipTransferRequest for the given token.
  #
  # Note that OwnershipTransferRequests that have already been accepted or
  # declined will not show up here and will generate a 404.
  #
  # @return [OwnershipTransferRequest]
  #
  def find_transfer_request
    @transfer_request = OwnershipTransferRequest.find_by!(
      token: params[:token],
      accepted: nil
    )
  end

  def transfer_ownership_params
    params.require(:cookbook).permit(:user_id, :add_owner_as_collaborator)
  end

  def add_owner_as_collaborator?
    transfer_ownership_params[:add_owner_as_collaborator] == "1"
  end
end
