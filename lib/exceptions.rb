# frozen_string_literal: true

module Exceptions
  class NotEmployee < StandardError; end
  class UserDidNotCheckIn < StandardError; end
  class UserAlreadyCheckedOut < StandardError; end
end
