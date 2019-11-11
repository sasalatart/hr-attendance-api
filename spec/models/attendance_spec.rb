# frozen_string_literal: true

# == Schema Information
#
# Table name: attendances
#
#  id          :uuid             not null, primary key
#  employee_id :uuid
#  entered_at  :datetime         not null
#  left_at     :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  timezone    :string           not null
#

require 'rails_helper'

RSpec.describe Attendance, type: :model do
  subject { build(:attendance) }

  describe 'associations' do
    it { should belong_to(:employee) }
  end

  describe 'validations' do
    describe 'employee' do
      %i[admin org_admin].each do |role|
        context "when the user it references is an #{role}" do
          it 'is not valid' do
            subject.employee = create(role)
            expect(subject).to_not be_valid
          end
        end
      end

      context 'when the user it references is an employee' do
        subject { build(:attendance, employee: create(:employee)) }
        it { should be_valid }
      end
    end

    describe 'entered_at' do
      it { should validate_presence_of(:entered_at) }
    end

    describe 'left_at' do
      it { should_not validate_presence_of(:left_at) }

      it 'must be after entered_at' do
        bod = DateTime.now.beginning_of_day - 1.day
        subject.entered_at = bod
        subject.left_at = bod - 1.hour
        expect(subject).to_not be_valid
        subject.left_at = bod + 1.hour
        expect(subject).to be_valid
      end

      it 'must be in the past' do
        attendance = build(:attendance, entered_at: 1.hour.from_now, left_at: 10.hours.from_now)
        expect(attendance).to_not be_valid
        attendance.entered_at = 10.hours.ago
        attendance.left_at = 1.hour.ago
        expect(attendance).to be_valid
      end

      context 'when there is another attendance with no left_at' do
        let(:employee) { create(:employee) }

        subject do
          build(:attendance, employee: employee,
                             entered_at: prev_attendance.entered_at + 1.day,
                             left_at: nil)
        end

        context 'when that attendance belongs to another employee' do
          let(:prev_attendance) { create(:attendance, entered_at: 2.days.ago, left_at: nil) }

          it 'can be nil' do
            expect(subject).to be_valid
          end
        end

        context 'when that attendance belongs to the same employee' do
          let(:prev_attendance) do
            create(:attendance, employee: employee, entered_at: 2.days.ago, left_at: nil)
          end

          it 'can not be nil' do
            expect(subject).to_not be_valid

            prev_attendance.left_at = prev_attendance.entered_at + 9.hours
            prev_attendance.save!
            expect(subject).to be_valid
          end
        end
      end

      context 'when there is another closed attendance chronologically after' do
        let(:employee) { create(:employee) }

        subject do
          build(:attendance, employee: employee,
                             entered_at: next_attendance.entered_at - 1.day,
                             left_at: nil)
        end

        context 'when that attendance belongs to another employee' do
          let(:next_attendance) { create(:attendance, entered_at: 2.days.ago, left_at: 1.day.ago) }

          it 'can be nil' do
            expect(subject).to be_valid
          end
        end

        context 'when that attendance belongs to the same employee' do
          let(:next_attendance) do
            create(:attendance, employee: employee, entered_at: 2.days.ago, left_at: 1.day.ago)
          end

          it 'can not be nil' do
            expect(subject).to_not be_valid

            next_attendance.destroy
            expect(subject).to be_valid
          end
        end
      end
    end

    describe 'timezone' do
      it { should validate_presence_of(:timezone) }

      it do
        timezones = ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.name }
        should validate_inclusion_of(:timezone).in_array timezones
      end
    end

    describe 'overlapping' do
      start_at = 6.days.ago.beginning_of_day
      end_at = 2.days.ago.beginning_of_day

      let(:employee) { create(:employee) }
      subject { build(:attendance, entered_at: entered_at, left_at: left_at, employee: employee) }

      before do
        create(:attendance, entered_at: start_at, left_at: end_at, employee: employee)
      end

      context 'when it overlaps completely inside another attendance' do
        let(:entered_at) { start_at + 1.day }
        let(:left_at) { end_at - 1.day }
        it { should_not be_valid }
      end

      context 'when another attendance overlaps completely inside it' do
        let(:entered_at) { start_at - 1.day }
        let(:left_at) { end_at + 1.day }
        it { should_not be_valid }
      end

      context 'when its entered_at overlaps, but not its left_at' do
        let(:entered_at) { start_at + 1.day }
        let(:left_at) { end_at + 1.day }
        it { should_not be_valid }
      end

      context 'when its left_at overlaps, but not its entered_at' do
        let(:entered_at) { start_at - 1.day }
        let(:left_at) { start_at + 1.day }
        it { should_not be_valid }
      end

      context 'when neither its entered_at nor its left_at overlaps with another attendance' do
        let(:entered_at) { start_at - 18.hours }
        let(:left_at) { start_at - 9.hours }
        it { should be_valid }
      end
    end
  end

  describe 'serialization' do
    let(:attendance) { create(:attendance, entered_at: 10.hours.ago, left_at: 1.hour.ago) }
    subject { AttendanceSerializer.new(attendance).as_json }

    it 'only serializes some attributes' do
      expect(subject.keys).to contain_exactly(
        :id,
        :employee_id,
        :employee_fullname,
        :entered_at,
        :left_at,
        :timezone,
        :updated_at,
        :created_at
      )
    end

    it 'serializes id' do
      expect(subject[:id]).to eql(attendance.id)
    end

    it 'serializes employee_id' do
      expect(subject[:employee_id]).to eql(attendance.employee_id)
    end

    it 'serializes employee_fullname' do
      employee = attendance.employee
      expected = %i[name surname second_surname].map do |attribute|
        employee[attribute]
      end.compact.join(' ')
      expect(subject[:employee_fullname]).to eql(expected)
    end

    it 'serializes entered_at' do
      expect(subject[:entered_at]).to eql(attendance.entered_at)
    end

    it 'serializes left_at' do
      expect(subject[:left_at]).to eql(attendance.left_at)
    end

    it 'serializes timezone' do
      expect(subject[:timezone]).to eql(attendance.timezone)
    end

    it 'serializes updated_at' do
      expect(subject[:updated_at]).to eql(attendance.updated_at)
    end

    it 'serializes created_at' do
      expect(subject[:created_at]).to eql(attendance.created_at)
    end
  end
end
