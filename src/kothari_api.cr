module KothariAPI
  VERSION = "2.5.0"
end

require "./kothari_api/db"
require "./kothari_api/migrator"
require "./kothari_api/router/route"
require "./kothari_api/controller"
require "./kothari_api/model"
require "./kothari_api/controller_registry"
require "./kothari_api/model_registry"
require "./kothari_api/auth/password"
require "./kothari_api/auth/jwt"
require "./kothari_api/validations"
require "./kothari_api/storage"
require "./kothari_api/cors"

