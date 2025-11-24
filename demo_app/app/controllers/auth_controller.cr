class AuthController < KothariAPI::Controller
  # POST /signup
  def signup
    data = json_body
    email = data["email"]?.try &.to_s
    password = data["password"]?.try &.to_s

    unless email && password
      context.response.status = HTTP::Status::BAD_REQUEST
      return json({error: "email and password are required"})
    end

    # Very simple duplicate check
    existing = User.find_by("email", email)
    if existing
      context.response.status = HTTP::Status::CONFLICT
      return json({error: "Email already taken"})
    end

    digest = KothariAPI::Auth::Password.hash(password.not_nil!)
    user = User.create(
      email: email.not_nil!,
      password_digest: digest
    )

    token = KothariAPI::Auth::JWTAuth.issue_simple({"email" => email.not_nil!})
    context.response.status = HTTP::Status::CREATED
    json({token: token, email: email.not_nil!})
  end

  # POST /login
  def login
    data = json_body
    email = data["email"]?.try &.to_s
    password = data["password"]?.try &.to_s

    unless email && password
      context.response.status = HTTP::Status::BAD_REQUEST
      return json({error: "email and password are required"})
    end

    user = User.find_by("email", email.not_nil!)

    unless user && KothariAPI::Auth::Password.verify(password.not_nil!, user.password_digest.not_nil!)
      context.response.status = HTTP::Status::UNAUTHORIZED
      return json({error: "Invalid email or password"})
    end

    token = KothariAPI::Auth::JWTAuth.issue_simple({"email" => email.not_nil!})
    json({token: token, email: email.not_nil!})
  end
end

KothariAPI::ControllerRegistry.register("auth", AuthController)