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
#

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { create(:user) }

    describe 'password' do
      it { should have_secure_password }
      it { should validate_confirmation_of(:password) }
    end

    describe 'email' do
      it { should validate_presence_of(:email) }
      it { should validate_uniqueness_of(:email).case_insensitive }
      it { should allow_values('user@example.org', 'user@example.cl').for(:email) }
      it { should_not allow_values('', 'user', 'user@', 'user@example', 'user@example.').for(:email) }
    end
  end

  describe 'attributes' do
    describe 'email' do
      it 'is downcased on save' do
        user = create(:user, email: 'User@Example.ORG')
        expect(user.email).to eql('user@example.org')
        user.update!(email: 'NEW-EMAIL@example.ORG')
        expect(user.email).to eql('new-email@example.org')
      end
    end
  end

  describe 'roles' do
    subject { create(:user) }

    it 'should default to employee' do
      expect(subject.has_role?(:employee)).to be true
    end
  end
end
