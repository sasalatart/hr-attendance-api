# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  it { should use_before_action(:authenticate_user) }

  it { should route(:get, '/organizations/id/users').to(action: :index, organization_id: 'id') }
  it { should route(:get, '/users/me').to(action: :me) }
  it { should route(:post, '/organizations/id/users').to(action: :create, organization_id: 'id') }
  it { should route(:put, '/users/id').to(action: :update, id: 'id') }
  it { should route(:delete, '/users/id').to(action: :destroy, id: 'id') }
end
