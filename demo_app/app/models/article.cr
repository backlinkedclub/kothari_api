class Article < KothariAPI::Model
  table "articles"

  @title : String
  @body : String
  @created_at : String?
  @updated_at : String?

  def initialize(@title : String, @body : String, @created_at : String? = nil, @updated_at : String? = nil)
  end

  # NOTE: This model is registered so tools like `kothari console`
  # can discover it by name.
  KothariAPI::ModelRegistry.register("article", Article)
end