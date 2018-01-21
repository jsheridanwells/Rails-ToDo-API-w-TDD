require 'rails_helper'

RSpec.describe AuthenticateUser do
  let(:user) { create(:user) }
  subject(:valid_auth_obj) { described_class.new(user.email, user.password) }
  subject(:invalid_auth_obj) { described_class.new('bad_email', 'bad_password') }

  describe '#call' do
    context 'when the credentials are valid' do
      it 'returns an auth token' do
        token = valid_auth_obj.call
        expect(token).not_to be(nil)
      end
    end

    context 'when the credentials are not valid' do
      it 'raises an authentication error' do
        expect { invalid_auth_obj.call }
          .to raise_error(
            ExceptionHandler::AuthenticationError,
            /Invalid credentials/
          )
      end
    end
  end
end