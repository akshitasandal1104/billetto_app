class ApplicationController < ActionController::Base
  helper_method :current_user
    # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  def current_user
    # Temporary stub (replace with Clerk in production)
    OpenStruct.new(id: session[:user_id] || 1)
  end

  def authenticate_user!
    redirect_to root_path, alert: "Please login" unless current_user
  end
end