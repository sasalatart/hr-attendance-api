# frozen_string_literal: true

class AttendancesController < ApplicationController
  before_action :authenticate_user

  load_and_authorize_resource

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
end
