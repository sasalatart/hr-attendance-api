# frozen_string_literal: true

RSpec.describe 'Organizations requests' do
  describe 'GET /organizations' do
    total = 30
    url = '/organizations'

    before do
      total.times { create(:organization) }
    end

    context 'when the user is not authenticated' do
      it 'responds with an unauthorized status' do
        get url
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is authenticated' do
      %i[org_admin employee].each do |role_name|
        context "when the user is an #{role_name}" do
          it 'responds with a forbidden status' do
            user = create(role_name)
            get url, headers: authenticated_header(user)
            expect(response).to have_http_status(:forbidden)
          end
        end
      end

      context 'when the user is an admin' do
        let(:admin) { create(:admin) }

        before { get url, headers: authenticated_header(admin) }

        it 'responds with an ok status' do
          expect(response).to have_http_status(:ok)
        end

        it 'responds with pagination headers' do
          expect(response.headers['x-page']).to eql('1')
          expect(response.headers['x-per-page']).to eql('25')
          expect(response.headers['x-total']).to eql(total.to_s)
        end

        it 'responds with the serialized organizations' do
          expected = Organization.all.limit(25).map do |organization|
            OrganizationSerializer.new(organization)
          end
          expect(response.body).to eql(expected.to_json)
        end
      end
    end
  end

  describe 'GET /organizations/:id' do
    let(:organization) { create(:organization) }
    let(:url) { "/organizations/#{organization.id}" }

    context 'when the user is not authenticated' do
      it 'responds with an unauthorized status' do
        get url
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is authenticated' do
      %i[org_admin employee].each do |role_name|
        context "when the user is an #{role_name}" do
          context 'when the user is not from that organization' do
            it 'responds with a forbidden status' do
              user = create(role_name)
              get url, headers: authenticated_header(user)
              expect(response).to have_http_status(:forbidden)
            end
          end

          context 'when the user is from that organization' do
            let(:user) { create(role_name, organization_id: organization.id) }

            before { get url, headers: authenticated_header(user) }

            it 'responds with an ok status' do
              expect(response).to have_http_status(:ok)
            end

            it 'responds with the serialized organization' do
              expect(response.body).to eql(OrganizationSerializer.new(organization).to_json)
            end
          end
        end
      end

      context 'when the user is an admin' do
        let(:admin) { create(:admin) }

        before { get url, headers: authenticated_header(admin) }

        it 'responds with an ok status' do
          expect(response).to have_http_status(:ok)
        end

        it 'responds with the serialized organization' do
          expect(response.body).to eql(OrganizationSerializer.new(organization).to_json)
        end
      end
    end
  end

  describe 'POST /organizations' do
    def create_organization(requesting_user = nil)
      headers = requesting_user ? authenticated_header(requesting_user) : {}
      post '/organizations', headers: headers, params: { name: 'created-org-name' }
    end

    context 'when the user is not authenticated' do
      it 'responds with an unauthorized status' do
        create_organization
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is authenticated' do
      %i[org_admin employee].each do |role_name|
        context "when the user is an #{role_name}" do
          it 'responds with a forbidden status' do
            user = create(role_name)
            create_organization(user)
            expect(response).to have_http_status(:forbidden)
          end
        end
      end

      context 'when the user is an admin' do
        let(:admin) { create(:admin) }

        before { create_organization(admin) }

        it 'responds with a created status' do
          expect(response).to have_http_status(:created)
        end

        it 'responds with the serialized created organization' do
          id = ActiveSupport::JSON.decode(response.body)['id']
          organization = Organization.find(id)
          expect(response.body).to eql(OrganizationSerializer.new(organization).to_json)
        end
      end
    end
  end

  describe 'PUT /organizations/:id' do
    let(:organization) { create(:organization, name: 'org-name') }

    def update_organization(name, requesting_user = nil)
      headers = requesting_user ? authenticated_header(requesting_user) : {}
      put "/organizations/#{organization.id}", headers: headers, params: { name: name }
    end

    context 'when the user is not authenticated' do
      it 'responds with an unauthorized status' do
        update_organization('name-a')
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is authenticated' do
      %i[org_admin employee].each do |role_name|
        context "when the user is an #{role_name}" do
          it 'responds with a forbidden status' do
            user = create(role_name, organization: organization)
            update_organization('name-b', user)
            expect(response).to have_http_status(:forbidden)
          end
        end
      end

      context 'when the user is an admin' do
        let(:admin) { create(:admin) }
        let(:updated_organization) { Organization.find(organization.id) }
        name = 'name-from-admin'

        before { update_organization(name, admin) }

        it 'responds with an ok status' do
          expect(response).to have_http_status(:ok)
        end

        it 'responds with the serialized updated organization' do
          expect(response.body).to eql(OrganizationSerializer.new(updated_organization).to_json)
        end

        it 'udpates the name' do
          expect(updated_organization.name).to eql(name)
        end
      end
    end
  end

  describe 'DELETE /organizations/:id' do
    let(:organization) { create(:organization) }

    def destroy_organization(requesting_user = nil)
      headers = requesting_user ? authenticated_header(requesting_user) : {}
      delete "/organizations/#{organization.id}", headers: headers
    end

    context 'when the user is not authenticated' do
      it 'responds with an unauthorized status' do
        destroy_organization
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is authenticated' do
      %i[org_admin employee].each do |role_name|
        context "when the user is an #{role_name}" do
          it 'responds with a forbidden status' do
            user = create(role_name, organization: organization)
            destroy_organization(user)
            expect(response).to have_http_status(:forbidden)
          end
        end
      end

      context 'when the user is an admin' do
        let(:admin) { create(:admin) }

        before { destroy_organization(admin) }

        it 'responds with a no_content status' do
          expect(response).to have_http_status(:no_content)
        end

        it 'destroys the organization' do
          expect(Organization.find_by(id: organization.id)).to be nil
        end
      end
    end
  end
end
