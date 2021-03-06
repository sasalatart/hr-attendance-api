# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user, params)
    return unless user

    @user = user
    @params = params

    if user.admin?
      can :manage, :all
      cannot %i[check_in check_out], Attendance
      return
    end

    org_admin_only_permissions if user.org_admin?
    employee_only_permissions if user.employee?

    can :show, Organization, id: user.organization_id
    can :me, User
  end

  def org_admin_only_permissions
    can :attendances, Organization, id: @user.organization_id
    can :index, User if @params[:organization_id] == @user.organization_id
    can %i[show attendances create update destroy], User, organization_id: @user.organization_id
    can %i[create update destroy], Attendance, employee_id: @user.organization.users.pluck(:id)
  end

  def employee_only_permissions
    can :attendances, User, id: @user.id
    can %i[check_in check_out], Attendance
  end
end
