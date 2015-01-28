class AssetDecorator < LittleDecorator
  def name
    if current_user.see_asset_id?
      "#{model.name} (#{model.asset_id})"
    else
      model.name
    end
  end

  def as_json(options={})
    {id: model.id, name: name}
  end
end
