module ClerkAuthHelpers
  FAKE_USER_ID = "user_test_abc123"

  # Call this in a spec to simulate an authenticated Clerk session.
  # Stubs the SDK's verify_token so no real HTTP call is made.
  def sign_in_as_clerk_user(user_id: FAKE_USER_ID, extra_claims: {})
    claims = { "sub" => user_id }.merge(extra_claims)
    sdk_double = instance_double(Clerk::SDK, verify_token: claims)
    allow(Clerk::SDK).to receive(:new).and_return(sdk_double)

    # Place a fake session cookie so ApplicationController picks it up
    cookies[:__session] = "fake.clerk.token"
  end

  # Call this to simulate an unauthenticated request (no valid token).
  def sign_out_clerk_user
    sdk_double = instance_double(Clerk::SDK)
    allow(sdk_double).to receive(:verify_token)
      .and_raise(Clerk::Errors::JWTVerificationError, "invalid token")
    allow(Clerk::SDK).to receive(:new).and_return(sdk_double)

    cookies.delete(:__session)
  end
end

RSpec.configure do |config|
  config.include ClerkAuthHelpers, type: :request
  config.include ClerkAuthHelpers, type: :system
end
