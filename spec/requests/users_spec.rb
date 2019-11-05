# frozen_string_literal: true

RSpec.describe 'Users requests' do
  describe 'GET /users/me' do
    url = '/users/me'

    context 'when the user is not authenticated' do
      it 'responds with an unauthorized status' do
        get url
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is authenticated' do
      let(:user) { create(:admin) }

      before { get url, headers: authenticated_header(user) }

      it 'responds with an ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'responds with the serialized requesting user' do
        expect(response.body).to eql(UserSerializer.new(user).to_json)
      end
    end
  end
end
