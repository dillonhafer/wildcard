class WildcardController < ApplicationController
  before_filter :select_user, :fields_for_user

  def index
    @assets = Asset.order(:name)
    if params[:name].present?
      @assets = @assets.search_in_fields(@fields, params[:name].downcase)
    end
  end

  private

  def fields_for_user
    @fields = [:name]
    @fields << :asset_id if User.current_user.see_asset_id?
    @fields
  end

  def select_user
    if params[:authorized] && params[:authorized] == 'true'
      User.current_user = authorized_user
    else
      User.current_user = unauthorized_user
    end
  end
end
