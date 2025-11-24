class Comment < KothariAPI::Model
  table "comments"

  @content : String
  @article_id : Int32
  @created_at : String?
  @updated_at : String?

  property content : String
  property article_id : Int32
  property created_at : String?
  property updated_at : String?

  def initialize(@content : String, @article_id : Int32, @created_at : String? = nil, @updated_at : String? = nil)
  end

  KothariAPI::ModelRegistry.register("comment", Comment)
end