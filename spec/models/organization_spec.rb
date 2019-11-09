# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe 'associations' do
    it { should have_many(:users) }
    it { should have_many(:attendances) }
  end

  describe 'validations' do
    subject { create(:organization) }

    describe 'name' do
      it { should validate_presence_of(:name) }
      it { should validate_uniqueness_of(:name).case_insensitive }
    end
  end

  describe '#destroy' do
    let(:organization) { create(:organization, org_admin_count: 1, employee_count: 5) }

    it 'cascade destroys all users from the organization' do
      organization.destroy
      expect(User.where(organization_id: organization.id).count).to be 0
    end
  end
end
