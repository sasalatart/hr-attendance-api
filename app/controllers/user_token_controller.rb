# frozen_string_literal: true

class UserTokenController < Knock::AuthTokenController
  include ExceptionHandler

  skip_before_action :verify_authenticity_token
end
