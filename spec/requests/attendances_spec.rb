# frozen_string_literal: true

RSpec.describe 'Attendances requests' do
  describe 'POST /attendances/check-ins' do
    let(:http_method) { :post }
    let(:url) { '/attendances/check-ins' }

    it_behaves_like 'a request that needs authentication'

    context 'when the user is authenticated' do
      context 'when the user is an org admin' do
        let(:requester) { create(:org_admin) }
        it_behaves_like 'a forbidden request'
      end

      context 'when the user is an employee' do
        now = DateTime.now

        let(:requester) { create(:employee) }
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
      end
    end
  end

  describe 'PUT /attendances/check-outs' do
    let(:http_method) { :put }
    let(:url) { '/attendances/check-outs' }

    it_behaves_like 'a request that needs authentication'

    context 'when the user is authenticated' do
      context 'when the user is an org admin' do
        let(:requester) { create(:org_admin) }
        it_behaves_like 'a forbidden request'
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
end
