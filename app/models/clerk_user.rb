ClerkUser = Data.define(:id, :claims) do
  def email
    claims["email"]
  end
end
