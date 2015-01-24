class User
  attr_accessor :roles

  def initialize(roles=[])
    @roles = roles
  end

  def see_asset_id?
    permitted = ['AccountOwner', 'BcTeam']
    (roles & permitted).any?
  end

  def User.current_user=(new_user)
    Thread.current[:current_user] = new_user
  end

  def User.current_user
    Thread.current[:current_user]
  end
end
