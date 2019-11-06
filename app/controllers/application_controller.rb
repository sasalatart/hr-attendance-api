# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ExceptionHandler
  include Knock::Authenticable
  include CanCan::ControllerAdditions

  before_action :set_locale

  protected

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, params)
  end
end
