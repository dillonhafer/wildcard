class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authorized_user
    User.new ['AccountOwner', 'BcTeam']
  end

  def unauthorized_user
    User.new
  end
end
