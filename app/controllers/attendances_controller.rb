# frozen_string_literal: true

class AttendancesController < ApplicationController
  before_action :authenticate_user

  load_and_authorize_resource

  def create
    @attendance.save!
    render json: @attendance, status: :created
  end

  def update
    @attendance.update!(update_params)
    render json: @attendance
  end

  def destroy
    @attendance.destroy
    render status: :no_content
  end

  def check_in
    render json: current_user.check_in!, status: :created
  end

  def check_out
    render json: current_user.check_out!
  rescue Exceptions::UserDidNotCheckIn
    render json: i18n_error(:user_did_not_check_in), status: 400
  rescue Exceptions::UserAlreadyCheckedOut
    render json: i18n_error(:user_already_checked_out), status: 400
  end

  private

  def attendance_params
    params.permit(:id, :employee_id, :entered_at, :left_at, :timezone)
  end

  def update_params
    params.permit(:id, :entered_at, :left_at, :timezone)
  end
end
