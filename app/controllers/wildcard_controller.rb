class WildcardController < ApplicationController
  def search
    @assets = Asset.none

    if params[:ids].present?
      ids = params[:ids].split(',').map(&:to_i)
      @assets = decorate(Asset.where("id in (?)", ids))
    end
  end

  def name_autocomplete
    assets = Asset.search_in_fields(allowed_fields, params[:q].downcase)
    render json: decorate(assets)
  end

  private

  def allowed_fields
    fields = [:name]
    fields << :asset_id if current_user.see_asset_id?
    fields
  end
end
