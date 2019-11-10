# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :authenticate_user

  load_and_authorize_resource

  def index
    paginate json: Organization.all
  end

  def show
    render json: @organization
  end

  def attendances
    paginate json: @organization.attendances.joins(:employee).order(entered_at: :desc)
  end

  def create
    @organization.save!
    render json: @organization, status: :created
  end

  def update
    @organization.update!(organization_params)
    render json: @organization
  end

  def destroy
    @organization.destroy
    render status: :no_content
  end

  private

  def organization_params
    params.permit(:name)
  end
end
