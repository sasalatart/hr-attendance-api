# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from CanCan::AccessDenied do
      render json: i18n_error(:forbidden), status: :forbidden
    end

    rescue_from ActiveRecord::RecordNotFound do
      render json: i18n_error(:not_found), status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { error: e.message }, status: :unprocessable_entity
    end

    rescue_from JWT::ExpiredSignature do
      render json: i18n_error(:token_expired), status: :unauthorized
    end
  end

  private

  def i18n_error(key)
    { error: I18n.t("errors.messages.#{key}", locale: params[:locale]) }
  end
end
