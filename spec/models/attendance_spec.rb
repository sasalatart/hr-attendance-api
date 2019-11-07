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

bod = DateTime.now.beginning_of_day
eod = DateTime.now.end_of_day

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
        subject.entered_at = bod
        subject.left_at = bod - 1.hour
        expect(subject).to_not be_valid
        subject.left_at = bod + 1.hour
        expect(subject).to be_valid
      end
    end

    describe 'registries per day' do
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
        # same timestamps
        [{ e_at: bod, l_at: eod }, { e_at: bod, l_at: eod }],
        # same entered_at, different left_at, but within same day
        [{ e_at: bod, l_at: eod }, { e_at: bod, l_at: eod - 1.hour }],
        # same entered_at, different left_at in different days
        [{ e_at: bod, l_at: eod }, { e_at: bod, l_at: eod + 1.hour }],
        # different entered_at but in same day, different left_at in different days
        [{ e_at: bod, l_at: eod }, { e_at: bod, l_at: eod + 1.hour }],
        # same left_at, different entered_at, but within same day
        [{ e_at: bod + 1.hour, l_at: eod }, { e_at: bod, l_at: eod }],
        # same left_at, different entered_at in different days
        [{ e_at: bod - 1.hour, l_at: eod }, { e_at: bod, l_at: eod }]
      ].each do |stamps|
        it_behaves_like 'not able to have two registries in a same day', stamps
      end
    end
  end
end
