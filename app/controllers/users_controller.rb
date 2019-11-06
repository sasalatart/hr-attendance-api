# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user

  load_and_authorize_resource

  def index
    paginate json: User.where(role: params[:role], organization_id: params[:organization_id])
  end

  def me
    render json: current_user, status: :ok
  end

  def create
    @user.save!
    render json: @user, status: :created
  end

  def update
    @user.update!(update_params)
    render json: @user
  end

  def destroy
    @user.destroy
    render status: :no_content
  end

  private

  def user_params
    params.permit(
      :role,
      :organization_id,
      :email,
      :password,
      :password_confirmation,
      :name,
      :surname,
      :second_surname
    )
  end

  def update_params
    params.permit(
      :email,
      :password,
      :password_confirmation,
      :name,
      :surname,
      :second_surname
    )
  end
end
