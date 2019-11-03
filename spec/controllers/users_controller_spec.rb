# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  it { should use_before_action(:authenticate_user) }

  it { should route(:get, '/users/me').to(action: :me) }
end
