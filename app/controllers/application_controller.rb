class ApplicationController < ActionController::Base
  helper_method :current_user, :user_signed_in?

  allow_browser versions: :modern
  stale_when_importmap_changes

  def current_user
    return @current_user if defined?(@current_user)

    session_token = clerk_session_token
    return @current_user = nil unless session_token

    begin
      claims = Clerk::SDK.new.verify_token(session_token)
      @current_user = ClerkUser.new(id: claims["sub"], claims: claims)
    rescue Clerk::Errors::JWTVerificationError, Clerk::Errors::DecodeError => e
      Rails.logger.warn("Clerk token verification failed: #{e.message}")
      @current_user = nil
    end
  end

  def user_signed_in?
    current_user.present?
  end

  def authenticate_user!
    unless user_signed_in?
      redirect_to clerk_sign_in_url, allow_other_host: true
    end
  end

  private

  def clerk_session_token
    # Clerk sends the session JWT in the __session cookie (server-rendered apps)
    # or as a Bearer token for API requests
    cookies[:__session] ||
      request.headers["Authorization"]&.delete_prefix("Bearer ")
  end

  def clerk_sign_in_url
    publishable_key = ENV.fetch("CLERK_PUBLISHABLE_KEY", "")
    frontend_api = publishable_key.sub(/^pk_(test|live)_/, "")
    "https://#{Base64.decode64(frontend_api + "==").chomp("$")}/sign-in"
  rescue
    root_url
  end
end
