# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AttendancesController, type: :controller do
  it { should route(:post, '/attendances/check-ins').to(action: :check_in) }
  it { should route(:put, '/attendances/check-outs').to(action: :check_out) }
end
