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
        bod = DateTime.now.beginning_of_day
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

    describe 'registries per day' do
      bod = DateTime.now.beginning_of_day - 1.week

      shared_examples_for 'not able to have two registries in a same day' do |stamps|
        subject do
          build(:attendance, entered_at: stamps[0][:e_at], left_at: stamps[0][:l_at])
        end

        before do
          create(
            :attendance, employee: other_attendance_employee,
                         entered_at: stamps[1][:e_at],
                         left_at: stamps[1][:l_at]
          )
        end

        context 'when the other attendance belongs to the same employee' do
          let(:other_attendance_employee) { subject.employee }
          it { should_not be_valid }
        end

        context 'when the other attendance belongs to another employee' do
          let(:other_attendance_employee) { create(:employee) }
          it { should be_valid }
        end
      end

      [
        # different entered_at but in same day, different left_at in a different day
        [
          { e_at: bod, l_at: bod + 9.hours },
          { e_at: bod + 20.hours, l_at: bod + 29.hours }
        ],
        # different entered_at in a different day, different left_at in the same day
        [
          { e_at: bod - 1.hour, l_at: bod + 8.hours },
          { e_at: bod + 10.hours, l_at: bod + 19.hours }
        ]
      ].each do |stamps|
        it_behaves_like 'not able to have two registries in a same day', stamps
      end
    end
  end
end
