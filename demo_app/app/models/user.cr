class User < KothariAPI::Model
  table "users"

  include KothariAPI::Auth::Password

  @email : String
  @password_digest : String
  @created_at : String?
  @updated_at : String?

  def initialize(@email : String, @password_digest : String, @created_at : String? = nil, @updated_at : String? = nil)
  end

  KothariAPI::ModelRegistry.register("user", User)
end