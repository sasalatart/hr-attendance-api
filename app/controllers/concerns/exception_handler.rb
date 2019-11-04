# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do
      render json: i18n_error('errors.not_found'), status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { error: e.message }, status: :unprocessable_entity
    end

    rescue_from JWT::ExpiredSignature do
      render json: i18n_error('errors.token_expired'), status: :unauthorized
    end
  end

  private

  def i18n_error(key)
    { error: I18n.t(key, locale: params[:locale]) }
  end
end
