class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def ensure_coordinator_or_admin!
    deny_access unless current_user.coordinator? || current_user.admin?
  end

  def ensure_admin!
    deny_access unless current_user.admin?
  end

  private

  def deny_access
    flash[:alert] = 'Access Denied'
    redirect_to root_path
  end
end
