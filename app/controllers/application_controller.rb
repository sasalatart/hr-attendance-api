# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ExceptionHandler
  include Knock::Authenticable

  before_action :set_locale

  protected

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
