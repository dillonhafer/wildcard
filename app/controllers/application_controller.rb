class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :select_user

  helper_method \
  def current_user
    User.current_user
  end

  def authorized_user
    User.new ['AccountOwner', 'BcTeam']
  end

  def unauthorized_user
    User.new
  end

  def select_user
    if params[:authorized] && params[:authorized] == 'true'
      User.current_user = authorized_user
    else
      User.current_user = unauthorized_user
    end
  end
end
