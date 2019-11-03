# frozen_string_literal: true

RSpec.describe 'Users requests' do
  describe 'GET /users/me' do
    URL = '/users/me'

    context 'when the user is not authenticated' do
      it 'responds with an unauthorized status' do
        get URL
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user is authenticated' do
      let(:user) { create(:user) }

      before { get URL, headers: authenticated_header(user) }

      it 'responds with an ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'responds with the serialized requesting user' do
        expect(response.body).to eql(
          { id: user.id,
            email: user.email,
            updated_at: user.updated_at,
            created_at: user.created_at }.to_json
        )
      end
    end
  end
end
