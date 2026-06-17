Clerk.configure do |c|
  c.secret_key = ENV.fetch("CLERK_SECRET_KEY", nil)
end
