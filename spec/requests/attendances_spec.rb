# frozen_string_literal: true

RSpec.describe 'Attendances requests' do
  describe 'POST /attendances/check-ins' do
    let(:http_method) { :post }
    let(:url) { '/attendances/check-ins' }

    it_behaves_like 'a request that needs authentication'

    context 'when the user is authenticated' do
      %i[admin org_admin].each do |role|
        context "when the user is an #{role}" do
          let(:requester) { create(role) }
          it_behaves_like 'a forbidden request'
        end
      end

      context 'when the user is an employee' do
        now = DateTime.now
        timezone = 'America/Santiago'

        let(:requester) { create(:employee, timezone: timezone) }
        let(:expected) { Attendance.order(created_at: :asc).last }

        before do
          allow(DateTime).to receive(:now).and_return(now)
          post url, headers: authenticated_header(requester)
        end

        it_behaves_like 'a created request'

        it 'responds with the serialized, persisted attendance' do
          expect(response.body).to eql(AttendanceSerializer.new(expected).to_json)
        end

        it 'assigns a timestamp to the entered_at value' do
          expect(expected.entered_at.to_i).to be(now.to_i)
        end

        it "assigns the user's timezone to the attendance" do
          expect(expected.timezone).to eql(timezone)
        end
      end
    end
  end

  describe 'PUT /attendances/check-outs' do
    let(:http_method) { :put }
    let(:url) { '/attendances/check-outs' }

    it_behaves_like 'a request that needs authentication'

    context 'when the user is authenticated' do
      %i[admin org_admin].each do |role|
        context "when the user is an #{role}" do
          let(:requester) { create(role) }
          it_behaves_like 'a forbidden request'
        end
      end

      context 'when the user is an employee' do
        let(:requester) { create(:employee) }

        before do
          requester.check_in!
          put url, headers: authenticated_header(requester)
        end

        it_behaves_like 'an ok request'

        it 'responds with the serialized, persisted attendance' do
          expected = requester.attendances.last
          expect(response.body).to eql(AttendanceSerializer.new(expected).to_json)
        end

        it 'assigns a timestamp to the left_at value' do
          expect(requester.attendances.last.left_at).to be_present
        end
      end
    end
  end

  describe 'POST /employees/:employee_id/attendances' do
    let(:http_method) { :post }
    let(:url) { "/employees/#{target_employee.id}/attendances" }
    valid_body = { entered_at: 10.hours.ago, left_at: 1.hour.ago, timezone: 'America/Santiago' }
    let(:body) { valid_body }

    let(:organization) { create(:organization) }
    let(:target_employee) { create(:employee, organization: organization) }

    it_behaves_like 'a request that needs authentication'

    context 'when the requesting user is an employee' do
      let(:requester) { create(:employee, organization: organization) }

      context 'when the target employee is from another organization' do
        let(:target_employee) { create(:employee) }
        it_behaves_like 'a forbidden request'
      end

      context 'when the target user is from the same organization' do
        it_behaves_like 'a forbidden request'
      end
    end

    context 'when the requesting user is an org_admin' do
      let(:requester) { create(:org_admin, organization: organization) }

      context 'when the target employee is from another organization' do
        let(:target_employee) { create(:employee) }
        it_behaves_like 'a forbidden request'
      end

      context 'when the target user is from the same organization' do
        before do
          post url, headers: authenticated_header(requester), params: body
          id = ActiveSupport::JSON.decode(response.body)['id']
          @attendance = Attendance.find(id)
        end

        it_behaves_like 'a created request'

        it 'responds with the serialized created attendance' do
          expect(response.body).to eql(AttendanceSerializer.new(@attendance).to_json)
        end

        it 'sets the entered_at value' do
          expect(@attendance.entered_at.to_i).to be(body[:entered_at].to_i)
        end

        it 'sets the left_at value' do
          expect(@attendance.left_at.to_i).to be(body[:left_at].to_i)
        end

        it 'sets the specified employee' do
          expect(@attendance.employee_id).to eql(target_employee.id)
        end

        it 'sets the specified timezone' do
          expect(@attendance.timezone).to eql(body[:timezone])
        end
      end
    end
  end

  describe 'PUT /attendances/:id' do
    let(:http_method) { :put }
    let(:url) { "/attendances/#{target_attendance.id}" }
    valid_body = { entered_at: 10.hours.ago, left_at: 1.hour.ago, timezone: 'America/Santiago' }
    let(:body) { valid_body }

    let(:organization) { create(:organization) }
    let(:target_attendance) do
      create(:attendance, employee: create(:employee, organization: organization))
    end

    it_behaves_like 'a request that needs authentication'

    context 'when the requesting user is an employee' do
      context 'when the target attendance is from another organization' do
        let(:requester) { create(:employee) }
        it_behaves_like 'a forbidden request'
      end

      context 'when the target attendance is from the same organization' do
        context 'when the employee is not the owner of the attendance' do
          let(:requester) { create(:employee, organization: organization) }
          it_behaves_like 'a forbidden request'
        end

        context 'when the employee is the owner of the attendance' do
          let(:requester) { target_attendance.employee }
          it_behaves_like 'a forbidden request'
        end
      end
    end

    context 'when the requesting user is an org_admin' do
      let(:requester) { create(:org_admin, organization: organization) }

      context 'when the target attendance is from another organization' do
        let(:requester) { create(:org_admin) }
        it_behaves_like 'a forbidden request'
      end

      context 'when the target attendance is from the same organization' do
        before do
          another_employee = create(:employee, organization: organization)
          put url, headers: authenticated_header(requester),
                   params: body.merge(employee_id: another_employee.id)
          id = ActiveSupport::JSON.decode(response.body)['id']
          @attendance = Attendance.find(id)
        end

        it_behaves_like 'an ok request'

        it 'responds with the serialized attendance' do
          expect(response.body).to eql(AttendanceSerializer.new(@attendance).to_json)
        end

        it 'sets the entered_at value' do
          expect(@attendance.entered_at.to_i).to be(body[:entered_at].to_i)
        end

        it 'sets the left_at value' do
          expect(@attendance.left_at.to_i).to be(body[:left_at].to_i)
        end

        it 'does not change the employee' do
          expect(@attendance.employee_id).to eql(target_attendance.employee_id)
        end

        it 'sets the timezone value' do
          expect(@attendance.timezone).to eql(body[:timezone])
        end
      end
    end
  end

  describe 'DELETE /attendances/:id' do
    let(:http_method) { :delete }
    let(:url) { "/attendances/#{target_attendance.id}" }

    let(:organization) { create(:organization) }
    let(:target_attendance) do
      create(:attendance, employee: create(:employee, organization: organization))
    end

    it_behaves_like 'a request that needs authentication'

    context 'when the requesting user is an employee' do
      context 'when the target attendance is from another organization' do
        let(:requester) { create(:employee) }
        it_behaves_like 'a forbidden request'
      end

      context 'when the target attendance is from the same organization' do
        context 'when the employee is not the owner of the attendance' do
          let(:requester) { create(:employee, organization: organization) }
          it_behaves_like 'a forbidden request'
        end

        context 'when the employee is the owner of the attendance' do
          let(:requester) { target_attendance.employee }
          it_behaves_like 'a forbidden request'
        end
      end
    end

    context 'when the requesting user is an org_admin' do
      let(:requester) { create(:org_admin, organization: organization) }

      context 'when the target attendance is from another organization' do
        let(:requester) { create(:org_admin) }
        it_behaves_like 'a forbidden request'
      end

      context 'when the target attendance is from the same organization' do
        before { delete url, headers: authenticated_header(requester) }

        it_behaves_like 'a no_content request'

        it 'destroys the attendance' do
          expect(Attendance.find_by(id: target_attendance.id)).to be nil
        end
      end
    end
  end
end
