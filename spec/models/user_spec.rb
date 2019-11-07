# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :uuid             not null, primary key
#  email           :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  role            :integer          not null
#  organization_id :uuid
#  name            :string           not null
#  surname         :string           not null
#  second_surname  :string
#

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should belong_to(:organization).optional }
    it { should have_many(:attendances) }
  end

  describe 'validations' do
    describe 'role' do
      it { should validate_presence_of(:role) }
    end

    describe 'organization_id' do
      let(:organization) { create(:organization) }

      context 'when the role is admin' do
        it 'can not be present' do
          user = create(:admin)
          user.organization = organization
          expect(user.valid?).to be false
          user.organization = nil
          expect(user.valid?).to be true
        end
      end

      %i[org_admin employee].each do |role|
        context "when the role is #{role}" do
          it 'must be present' do
            user = create(role)
            user.organization = nil
            expect(user).to_not be_valid
            user.organization = organization
            expect(user).to be_valid
          end
        end
      end
    end

    describe 'email' do
      subject { create(:admin) }

      it { should validate_presence_of(:email) }
      it { should validate_uniqueness_of(:email).case_insensitive }
      it { should allow_values('user@example.org', 'user@example.cl').for(:email) }

      it do
        should_not allow_values('', 'user', 'user@', 'user@example', 'user@example.').for(:email)
      end
    end

    describe 'name' do
      it { should validate_presence_of(:name) }
    end

    describe 'surname' do
      it { should validate_presence_of(:surname) }
    end

    describe 'second_surname' do
      it { should_not validate_presence_of(:second_surname) }
    end

    describe 'password' do
      it { should have_secure_password }
      it { should validate_confirmation_of(:password) }
    end
  end

  describe 'attributes' do
    describe 'email' do
      it 'is downcased on save' do
        user = create(:admin, email: 'User@Example.ORG')
        expect(user.email).to eql('user@example.org')
        user.update!(email: 'NEW-EMAIL@example.ORG')
        expect(user.email).to eql('new-email@example.org')
      end
    end
  end
end
