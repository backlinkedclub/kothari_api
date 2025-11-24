module KothariAPI
  # Registry of models so tooling like `kothari console` can
  # discover and operate on them by name.
  module ModelRegistry
    @@models = {} of String => KothariAPI::Model.class

    # Register a model under a simple, lowercased name, e.g.
    #   KothariAPI::ModelRegistry.register("profile", Profile)
    def self.register(name : String, klass)
      @@models[name] = klass
    end

    def self.lookup(name : String)
      @@models[name]?
    end

    def self.all_names
      @@models.keys
    end
  end
end


