# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id            :uuid             not null, primary key
#  name          :string
#  resource_id   :uuid
#  resource_type :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'relations' do
    it { should belong_to(:resource).join_table('users_roles').optional }
  end

  describe 'validations' do
    describe 'resource_type' do
      it { should validate_inclusion_of(:resource_type).in_array(Rolify.resource_types) }
      it { should allow_value(nil).for(:resource_type) }
    end
  end
end
