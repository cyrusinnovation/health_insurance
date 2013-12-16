class HomeController < ApplicationController
  before_filter :authenticate_user!

  def index
    current_user.build_myrsc if current_user.myrsc.nil?
    current_user.oxfords.build
  end

  def cancel
    claim = Claim.where(claim_number: params[:claim_number]).first
    claim.mark_as_canceled if claim and claim.ready_for_processing? and claim.user == current_user
    redirect_to root_path, notice: 'Cancelled'
  end

  def submit_info
    current_user.update_attributes(params.require(:user).permit(myrsc_attributes: [ :username, :password, :id ], oxfords_attributes: [ :username, :password, :id, :relationship, :claimant]))
    current_user.build_myrsc if current_user.myrsc.nil?
    current_user.oxfords.build

    render :index
  end
end
