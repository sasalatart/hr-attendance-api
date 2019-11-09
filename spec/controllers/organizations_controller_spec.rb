# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationsController, type: :controller do
  it { should use_before_action(:authenticate_user) }

  it { should route(:get, '/organizations').to(action: :index) }
  it { should route(:get, '/organizations/an-id').to(action: :show, id: 'an-id') }
  it { should route(:get, '/organizations/id/attendances').to(action: :attendances, id: 'id') }
  it { should route(:post, '/organizations').to(action: :create) }
  it { should route(:put, '/organizations/an-id').to(action: :update, id: 'an-id') }
  it { should route(:delete, '/organizations/an-id').to(action: :destroy, id: 'an-id') }
end
