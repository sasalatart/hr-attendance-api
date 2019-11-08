# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttendancesController, type: :controller do
  it do
    should route(:post, '/employees/e-id/attendances').to(action: :create, employee_id: 'e-id')
  end
  it { should route(:put, '/attendances/id').to(action: :update, id: 'id') }
  it { should route(:delete, '/attendances/id').to(action: :destroy, id: 'id') }
  it { should route(:post, '/attendances/check-ins').to(action: :check_in) }
  it { should route(:put, '/attendances/check-outs').to(action: :check_out) }
end
