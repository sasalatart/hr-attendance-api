# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user, params)
    return unless user

    if user.admin?
      can :manage, :all
      return
    end

    if user.org_admin?
      can %i[index create], User if params[:organization_id] == user.organization_id
      can %i[update destroy], User, organization_id: user.organization_id
    end

    can :show, Organization, id: user.organization_id
    can :me, User
  end
end
