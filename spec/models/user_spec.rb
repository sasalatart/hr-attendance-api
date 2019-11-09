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

  describe '#check_in!' do
    %i[admin org_admin].each do |role|
      context "when the user is an #{role}" do
        subject { create(role) }

        it 'raises a NotEmployee error' do
          expect { subject.check_in! }.to raise_error(Exceptions::NotEmployee)
        end
      end
    end

    context 'when the user is an employee' do
      subject { create(:employee) }

      context 'when the user had already checked in' do
        before { subject.check_in! }

        it 'throws a validation error' do
          expect { subject.check_in! }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'when the user had not already checked in' do
        let(:attendance) { subject.check_in! }

        it 'creates a new attendance' do
          expect { subject.check_in! }.to change { Attendance.count }.by(1)
        end

        it 'returns a persisted attendance' do
          expect(attendance).to be_persisted
        end

        it 'assigns a timestamp to the entered_at attribute' do
          now = DateTime.now
          allow(DateTime).to receive(:now).and_return(now)
          expect(attendance.entered_at.to_i).to be(now.to_i)
        end

        it 'does not assign any value to the left_at attribute' do
          expect(attendance.left_at).to be_nil
        end

        it 'assigns the attendance to the user' do
          expect(attendance.employee).to eql(subject)
        end
      end
    end
  end

  describe '#check_out!' do
    %i[admin org_admin].each do |role|
      context "when the user is an #{role}" do
        subject { create(role) }

        it 'raises a NotEmployee error' do
          expect { subject.check_out! }.to raise_error(Exceptions::NotEmployee)
        end
      end
    end

    context 'when the user is an employee' do
      subject { create(:employee) }

      context 'when the user had not already checked in' do
        it 'throws a UserDidNotCheckIn error' do
          expect { subject.check_out! }.to raise_error(Exceptions::UserDidNotCheckIn)
        end
      end

      context 'when the user had already checked in' do
        context 'when the user had already checked out' do
          before do
            subject.check_in!
            subject.check_out!
          end

          it 'throws a UserAlreadyCheckedOut error' do
            expect { subject.check_out! }.to raise_error(Exceptions::UserAlreadyCheckedOut)
          end
        end

        context 'when the user had not already checked out' do
          let(:attendance) { subject.check_out! }
          before { subject.check_in! }

          it 'does not create a new attendance' do
            count_before = Attendance.count
            subject.check_out!
            expect(count_before).to be(Attendance.count)
          end

          it 'returns a persisted attendance' do
            expect(attendance).to be_persisted
          end

          it 'assigns a timestamp to the left_at attribute' do
            now = DateTime.now
            allow(DateTime).to receive(:now).and_return(now)
            expect(attendance.left_at.to_i).to be(now.to_i)
          end
        end
      end
    end
  end

  describe 'serialization' do
    %i[admin org_admin employee].each do |role|
      context "when the role is #{role}" do
        let(:user) do
          num_attendances = role == :employee ? 2 : 0
          create(role, second_surname: 'Second Surname', num_attendances: num_attendances)
        end
        subject { UserSerializer.new(user).as_json }

        it 'only serializes some attributes' do
          expect(subject.keys).to contain_exactly(
            :id,
            :role,
            :organization_id,
            :last_attendance,
            :email,
            :name,
            :surname,
            :second_surname,
            :updated_at,
            :created_at
          )
        end

        it 'serializes id' do
          expect(subject[:id]).to eql(user.id)
        end

        it 'serializes role' do
          expect(subject[:role]).to eql(role.to_s)
        end

        it 'serializes organization_id' do
          expect(subject[:organization_id]).to eql(user.organization_id)
        end

        if role == :employee
          it 'serializes last_attendance' do
            last_attendance = user.attendances.order(entered_at: :asc).last
            expected = AttendanceSerializer.new(last_attendance).as_json
            expect(subject[:last_attendance]).to eql(expected)
          end
        end

        it 'serializes email' do
          expect(subject[:email]).to eql(user.email)
        end

        it 'serializes name' do
          expect(subject[:name]).to eql(user.name)
        end

        it 'serializes surname' do
          expect(subject[:surname]).to eql(user.surname)
        end

        it 'serializes second_surname' do
          expect(subject[:second_surname]).to eql(user.second_surname)
        end

        it 'serializes updated_at' do
          expect(subject[:updated_at]).to eql(user.updated_at)
        end

        it 'serializes created_at' do
          expect(subject[:created_at]).to eql(user.created_at)
        end
      end
    end
  end
end
