RSpec.describe UsersController do
  let(:user) { build(:user) }
  let(:headers) { valid_headers.except('Authorization') }
  let(:valid_attributes) do
    attributes_for(:user, password_confirmation: user.password)
  end

  describe 'POST /signup' do
    context 'when it is a valid request' do
      before { post '/signup', params: valid_attributes.to_json, headers: headers }
      it 'creates a new user' do
        expect(response).to have_http_status(201)
      end
      it 'returns a success message' do
        expect(json['message']).to match(/Account created successfully/)
      end
      it 'returns an authentication token' do
        expect(json['auth_token']).not_to be_nil
      end
    end

    context 'when it is not a valid request' do
      before { post '/signup', params: {}, headers: headers }
      it 'does not create a new user' do
        expect(response).to have_http_status(422)
      end
      it 'returns a failure message' do
        expect(json['message'])
          .to match(/Validation failed/)
      end
    end
  end
end