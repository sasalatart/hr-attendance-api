# frozen_string_literal: true

require_relative './authentication'

def request(headers = nil)
  options = { headers: headers, params: body }

  return get url, options if http_method == :get
  return post url, options if http_method == :post
  return put url, options if http_method == :put

  delete url, options
end

shared_examples_for 'a request that needs authentication' do
  context 'when the request is not authenticated' do
    it 'responds with an unauthorized status' do
      request
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

shared_examples_for 'a forbidden request' do
  it 'responds with a forbidden status' do
    request(authenticated_header(requester))
    expect(response).to have_http_status(:forbidden)
  end
end

shared_examples_for 'an unprocessable_entity request' do
  it 'responds with an unprocessable_entity status' do
    request(authenticated_header(requester))
    expect(response).to have_http_status(:unprocessable_entity)
  end
end

shared_examples_for 'an ok request' do
  it 'responds with an ok status' do
    expect(response).to have_http_status(:ok)
  end
end

shared_examples_for 'a created request' do
  it 'responds with created status' do
    expect(response).to have_http_status(:created)
  end
end

shared_examples_for 'a no_content request' do
  it 'responds with no_content status' do
    expect(response).to have_http_status(:no_content)
  end
end

shared_examples_for 'a paginated request' do
  it 'responds with pagination headers' do
    expect(response.headers['x-page']).to be_truthy
    expect(response.headers['x-per-page']).to be_truthy
    expect(response.headers['x-total']).to be_truthy
  end
end
