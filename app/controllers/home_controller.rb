class HomeController < ApplicationController
  before_filter :authenticate_user!

  def index
    current_user.myrsc = Myrsc.new if current_user.myrsc.nil?
    current_user.oxfords.build
  end

  def submit_info
    current_user.update_attributes(params.require(:user).permit(myrsc_attributes: [ :username, :password, :id ], oxfords_attributes: [ :username, :password, :id, :relationship, :claimant]))

    redirect_to root_path
  end
end
