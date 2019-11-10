# frozen_string_literal: true

RSpec.describe 'Organizations requests' do
  describe 'GET /organizations' do
    let(:http_method) { :get }
    let(:url) { '/organizations' }
    total = 30

    before do
      total.times { create(:organization) }
    end

    it_behaves_like 'a request that needs authentication'

    context 'when the user is authenticated' do
      %i[org_admin employee].each do |role_name|
        context "when the user is an #{role_name}" do
          let(:requester) { create(role_name) }
          it_behaves_like 'a forbidden request'
        end
      end

      context 'when the user is an admin' do
        let(:requester) { create(:admin) }

        before { get url, headers: authenticated_header(requester) }

        it_behaves_like 'an ok request'
        it_behaves_like 'a paginated request'

        it 'responds with the serialized organizations' do
          expected = ActiveModel::Serializer::CollectionSerializer.new(
            Organization.all.limit(25),
            each_serializer: OrganizationSerializer
          )
          expect(response.body).to eql(expected.to_json)
        end
      end
    end
  end

  describe 'GET /organizations/:id' do
    let(:http_method) { :get }
    let(:url) { "/organizations/#{organization.id}" }
    let(:organization) { create(:organization) }
    let(:another_organization) { create(:organization) }

    shared_examples_for 'a successful show request' do
      before { get url, headers: authenticated_header(requester) }

      it_behaves_like 'an ok request'

      it 'responds with the serialized organization' do
        expect(response.body).to eql(OrganizationSerializer.new(organization).to_json)
      end
    end

    it_behaves_like 'a request that needs authentication'

    context 'when the user is authenticated' do
      %i[org_admin employee].each do |role_name|
        context "when the user is an #{role_name}" do
          context 'when the user is not from that organization' do
            let(:requester) { create(role_name, organization: another_organization) }
            it_behaves_like 'a forbidden request'
          end

          context 'when the user is from that organization' do
            let(:requester) { create(role_name, organization: organization) }
            it_behaves_like 'a successful show request'
          end
        end
      end

      context 'when the user is an admin' do
        let(:requester) { create(:admin) }
        it_behaves_like 'a successful show request'
      end
    end
  end

  describe 'GET /organizations/:id/attendances' do
    let(:http_method) { :get }
    let(:url) { "/organizations/#{organization.id}/attendances" }
    let(:organization) { create(:organization) }

    it_behaves_like 'a request that needs authentication'

    context 'when the user is authenticated' do
      context 'when the user is an employee' do
        context 'when the employee does not belong to the organization' do
          let(:requester) { create(:employee) }
          it_behaves_like 'a forbidden request'
        end

        context 'when the employee belongs to the organization' do
          let(:requester) { create(:employee, organization: organization) }
          it_behaves_like 'a forbidden request'
        end
      end

      context 'when the user is an org admin' do
        context 'when the org admin does not belong to the organization' do
          let(:requester) { create(:org_admin) }
          it_behaves_like 'a forbidden request'
        end

        context 'when the org admin belongs to the organization' do
          let(:requester) { create(:org_admin, organization: organization) }

          before do
            now = DateTime.now
            allow(DateTime).to receive(:now).and_return(now)

            2.times do
              create(:employee, organization: organization, num_attendances: 2)
              create(:employee, num_attendances: 2)
            end

            get url, headers: authenticated_header(requester)
          end

          it_behaves_like 'an ok request'
          it_behaves_like 'a paginated request'

          it 'responds with the serialized attendances from the specified organization only' do
            attendances = organization.attendances.order(entered_at: :desc)
            expected = ActiveModel::Serializer::CollectionSerializer.new(
              attendances,
              each_serializer: AttendanceSerializer
            )
            expect(response.body).to eql(expected.to_json)
          end
        end
      end
    end
  end

  describe 'POST /organizations' do
    let(:http_method) { :post }
    let(:url) { '/organizations' }
    valid_body = { name: 'created-org-name' }
    let(:body) { valid_body }

    it_behaves_like 'a request that needs authentication'

    context 'when the user is authenticated' do
      %i[org_admin employee].each do |role_name|
        context "when the user is an #{role_name}" do
          let(:requester) { create(role_name) }
          it_behaves_like 'a forbidden request'
        end
      end

      context 'when the user is an admin' do
        let(:requester) { create(:admin) }

        context 'when no name is sent' do
          let(:body) { { name: nil } }
          it_behaves_like 'an unprocessable_entity request'
        end

        context 'when a valid new name is sent' do
          before { post url, headers: authenticated_header(requester), params: body }

          it_behaves_like 'a created request'

          it 'responds with the serialized created organization' do
            id = ActiveSupport::JSON.decode(response.body)['id']
            organization = Organization.find(id)
            expect(response.body).to eql(OrganizationSerializer.new(organization).to_json)
          end
        end
      end
    end
  end

  describe 'PUT /organizations/:id' do
    let(:http_method) { :put }
    let(:url) { "/organizations/#{organization.id}" }
    valid_body = { name: 'new-org-name' }
    let(:body) { valid_body }
    let(:organization) { create(:organization) }

    it_behaves_like 'a request that needs authentication'

    context 'when the user is authenticated' do
      %i[org_admin employee].each do |role_name|
        context "when the user is an #{role_name}" do
          let(:requester) { create(role_name, organization: organization) }
          it_behaves_like 'a forbidden request'
        end
      end

      context 'when the user is an admin' do
        let(:requester) { create(:admin) }

        before do
          put url, headers: authenticated_header(requester), params: body
          @updated = Organization.find(organization.id)
        end

        it_behaves_like 'an ok request'

        it 'responds with the serialized updated organization' do
          expect(response.body).to eql(OrganizationSerializer.new(@updated).to_json)
        end

        it 'udpates the name' do
          expect(@updated.name).to eql(valid_body[:name])
        end
      end
    end
  end

  describe 'DELETE /organizations/:id' do
    let(:http_method) { :delete }
    let(:url) { "/organizations/#{organization.id}" }
    let(:organization) { create(:organization) }

    it_behaves_like 'a request that needs authentication'

    context 'when the user is authenticated' do
      %i[org_admin employee].each do |role_name|
        context "when the user is an #{role_name}" do
          let(:requester) { create(role_name, organization: organization) }
          it_behaves_like 'a forbidden request'
        end
      end

      context 'when the user is an admin' do
        let(:requester) { create(:admin) }
        before { delete url, headers: authenticated_header(requester) }

        it_behaves_like 'a no_content request'

        it 'destroys the organization' do
          expect(Organization.find_by(id: organization.id)).to be nil
        end
      end
    end
  end
end
