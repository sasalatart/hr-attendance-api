# frozen_string_literal: true

RSpec.describe 'Users requests' do
  describe 'GET /organizations/:organization_id/users' do
    let(:http_method) { :get }
    let(:url) { "/organizations/#{organization.id}/users" }
    let(:users_per_organization) { { org_admin_count: 5, employee_count: 10 } }
    let(:organization) { create(:organization, users_per_organization) }
    let(:another_organization) { create(:organization, users_per_organization) }

    shared_examples_for 'a successful users from organization request' do
      before do
        get url, headers: authenticated_header(requester), params: { role: queried_role }
      end

      it_behaves_like 'an ok request'
      it_behaves_like 'a paginated request'

      it 'responds with users from the requested organization with the queried role only' do
        from_org_and_role = JSON.parse(response.body).all? do |u|
          u['organization_id'] == organization.id && u['role'] == queried_role.to_s
        end
        expect(from_org_and_role).to be(true)
      end
    end

    it_behaves_like 'a request that needs authentication'

    context 'when the user is authenticated' do
      context 'when the user is an employee' do
        let(:requester) { create(:employee, organization: organization) }

        context 'when the specified organization is another one' do
          let(:url) { "/organizations/#{another_organization.id}/users" }
          it_behaves_like 'a forbidden request'
        end

        context 'when the requesting user belongs to the organization' do
          %i[org_admin employee].each do |queried_role|
            let(:queried_role) { queried_role }
            context "when the queried role is #{queried_role}" do
              it_behaves_like 'a forbidden request'
            end
          end
        end
      end

      context 'when the user is an org_admin' do
        let(:requester) { create(:org_admin, organization: organization) }

        context 'when the specified organization is another one' do
          let(:url) { "/organizations/#{another_organization.id}/users" }
          it_behaves_like 'a forbidden request'
        end

        context 'when the requesting user belongs to the organization' do
          %i[org_admin employee].each do |queried_role|
            let(:queried_role) { queried_role }
            context "when the queried role is #{queried_role}" do
              it_behaves_like 'a successful users from organization request'
            end
          end
        end
      end

      context 'when the user is an admin' do
        let(:requester) { create(:admin) }

        %i[org_admin employee].each do |queried_role|
          let(:queried_role) { queried_role }
          context "when the queried role is #{queried_role}" do
            it_behaves_like 'a successful users from organization request'
          end
        end
      end
    end
  end

  describe 'GET /users/me' do
    let(:http_method) { :get }
    let(:url) { '/users/me' }

    it_behaves_like 'a request that needs authentication'

    context 'when the user is authenticated' do
      let(:user) { create(:admin) }

      before { get url, headers: authenticated_header(user) }

      it_behaves_like 'an ok request'

      it 'responds with the serialized requesting user' do
        expect(response.body).to eql(UserSerializer.new(user).to_json)
      end
    end
  end

  describe 'POST /organizations/:id/users' do
    let(:http_method) { :post }
    let(:url) { "/organizations/#{organization.id}/users" }

    valid_body = { role: :employee,
                   email: 'creation-email@example.org',
                   password: 'creation-password',
                   password_confirmation: 'creation-password',
                   name: 'creation-name',
                   surname: 'creation-surname',
                   second_surname: 'creation-second-surname' }

    let(:body) { valid_body }
    let(:organization) { create(:organization) }
    let(:another_organization) { create(:organization) }

    shared_examples_for 'a successful create user request' do
      before do
        post url, headers: authenticated_header(requester), params: body
        id = ActiveSupport::JSON.decode(response.body)['id']
        @user = User.find(id)
      end

      it_behaves_like 'a created request'

      it 'responds with the serialized created user' do
        expect(response.body).to eql(UserSerializer.new(@user).to_json)
      end

      it 'sets the role' do
        expect(@user.role).to eql(body[:role].to_s)
      end

      it 'sets the email' do
        expect(@user.email).to eql(body[:email])
      end

      it 'sets the name' do
        expect(@user.name).to eql(body[:name])
      end

      it 'sets the surname' do
        expect(@user.surname).to eql(body[:surname])
      end

      it 'sets the second_surname' do
        expect(@user.second_surname).to eql(body[:second_surname])
      end

      it 'sets the password' do
        expect(@user.authenticate(body[:password])).to be_truthy
      end
    end

    it_behaves_like 'a request that needs authentication'

    context 'when the requesting user is an employee' do
      let(:requester) { create(:employee, organization: organization) }

      %i[admin org_admin employee].each do |role|
        context "when the user to be created is an #{role}" do
          let(:body) { valid_body.merge(role: role) }
          it_behaves_like 'a forbidden request'
        end
      end
    end

    context 'when the requesting user is an org_admin' do
      let(:requester) { create(:org_admin, organization: organization) }

      context 'when the user to be created is an admin' do
        let(:body) { valid_body.merge(role: :admin) }
        it_behaves_like 'an unprocessable_entity request'
      end

      %i[org_admin employee].each do |role|
        context "when the user to be created is an #{role}" do
          let(:body) { valid_body.merge(role: role) }

          context 'when the specified organization is another one' do
            let(:url) { "/organizations/#{another_organization.id}/users" }
            it_behaves_like 'a forbidden request'
          end

          context 'when the requesting user belongs to the organization' do
            it_behaves_like 'a successful create user request'
          end
        end
      end
    end

    context 'when the requesting user is an admin' do
      let(:requester) { create(:admin) }

      context 'when the user to be created is an admin' do
        let(:body) { valid_body.merge(role: :admin) }
        it_behaves_like 'an unprocessable_entity request'
      end

      %i[org_admin employee].each do |role|
        context "when the user to be created is an #{role}" do
          let(:body) { valid_body.merge(role: role) }
          it_behaves_like 'a successful create user request'
        end
      end
    end
  end

  describe 'PUT /users/:id' do
    let(:http_method) { :put }
    let(:url) { "/users/#{user_from_organization.id}" }

    valid_body = { email: 'update-user@example.org',
                   password: 'update-password',
                   password_confirmation: 'update-password',
                   name: 'update-name',
                   surname: 'update-surname',
                   second_surname: 'update-second-surname' }

    let(:body) { valid_body }

    let(:organization) { create(:organization) }
    let(:another_organization) { create(:organization) }
    let(:admin) { create(:admin) }
    let(:user_from_organization) { create(:employee, organization: organization) }
    let(:user_from_another_organization) { create(:employee, organization: another_organization) }

    shared_examples_for 'a successful update user request' do
      before do
        put url, headers: authenticated_header(requester),
                 params: body.merge(role: 'admin',
                                    organization_id: another_organization.id)
        id = ActiveSupport::JSON.decode(response.body)['id']
        @upated_user = User.find(id)
      end

      it_behaves_like 'an ok request'

      it 'responds with the serialized updated user' do
        expect(response.body).to eql(UserSerializer.new(@upated_user).to_json)
      end

      it 'updates the email' do
        expect(@upated_user.email).to eql(body[:email])
      end

      it 'updates the name' do
        expect(@upated_user.name).to eql(body[:name])
      end

      it 'updates the surname' do
        expect(@upated_user.surname).to eql(body[:surname])
      end

      it 'updates the second_surname' do
        expect(@upated_user.second_surname).to eql(body[:second_surname])
      end

      it 'does not update the role' do
        expect(@upated_user.role).to_not eql(body[:role])
        expect(@upated_user.role).to eql(user_from_organization.role)
      end

      it 'does not update the organization_id' do
        expect(@upated_user.organization_id).to_not eql(body[:organization_id])
        expect(@upated_user.organization_id).to eql(organization.id)
      end

      it 'updates the password' do
        expect(@upated_user.authenticate(body[:password])).to be_truthy
      end
    end

    it_behaves_like 'a request that needs authentication'

    context 'when it is an employee doing the request' do
      let(:requester) { create(:employee, organization: organization) }

      context 'when the target user is from the same organization' do
        it_behaves_like 'a forbidden request'
      end

      context 'when the target user is from another organization' do
        let(:url) { "/users/#{user_from_another_organization.id}" }
        it_behaves_like 'a forbidden request'
      end

      context 'when the target user is an admin' do
        let(:url) { "/users/#{admin.id}" }
        it_behaves_like 'a forbidden request'
      end
    end

    context 'when it is an org_admin doing the request' do
      let(:requester) { create(:org_admin, organization: organization) }

      context 'when the target user is from the same organization' do
        it_behaves_like 'a successful update user request'
      end

      context 'when the target user is from another organization' do
        let(:url) { "/users/#{user_from_another_organization.id}" }
        it_behaves_like 'a forbidden request'
      end

      context 'when the target user is an admin' do
        let(:url) { "/users/#{admin.id}" }
        it_behaves_like 'a forbidden request'
      end
    end

    context 'when it is an admin doing the request' do
      let(:requester) { admin }
      it_behaves_like 'a successful update user request'
    end
  end

  describe 'DELETE /users/:id' do
    let(:http_method) { :delete }
    let(:url) { "/users/#{target_user.id}" }
    let(:organization) { create(:organization) }
    let(:another_organization) { create(:organization) }
    let(:target_user) { create(:employee, organization: organization) }

    shared_examples_for 'a successful destroy user request' do
      before { delete url, headers: authenticated_header(requester) }

      it_behaves_like 'a no_content request'

      it 'destroys the user' do
        expect(User.find_by(id: target_user.id)).to be nil
      end
    end

    it_behaves_like 'a request that needs authentication'

    context 'when the user is authenticated' do
      context 'when the user is an employee' do
        let(:requester) { create(:employee, organization: organization) }

        context 'when the target user is from another organization' do
          let(:target_user) { create(:employee, organization: another_organization) }
          it_behaves_like 'a forbidden request'
        end

        context 'when the target user is from the same organization' do
          it_behaves_like 'a forbidden request'
        end

        context 'when the target user is an admin' do
          let(:target_user) { create(:admin) }
          it_behaves_like 'a forbidden request'
        end
      end

      context 'when the user is an org_admin' do
        let(:requester) { create(:org_admin, organization: organization) }

        context 'when the target user is from another organization' do
          let(:target_user) { create(:employee, organization: another_organization) }
          it_behaves_like 'a forbidden request'
        end

        context 'when the target user is an admin' do
          let(:target_user) { create(:admin) }
          it_behaves_like 'a forbidden request'
        end

        context 'when the target user is from the same organization' do
          it_behaves_like 'a successful destroy user request'
        end
      end

      context 'when the user is an admin' do
        let(:requester) { create(:admin) }
        it_behaves_like 'a successful destroy user request'
      end
    end
  end
end
