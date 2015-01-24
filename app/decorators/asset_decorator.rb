class AssetDecorator < LittleDecorator
  def name
    if User.current_user.see_asset_id?
      "#{model.name} (#{model.asset_id})"
    else
      model.name
    end
  end
end
