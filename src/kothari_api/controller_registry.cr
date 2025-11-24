module KothariAPI
  # Keeps a mapping from controller name (e.g. "profiles") to the
  # actual controller class. Apps register their controllers in
  # their files like:
  #
  #   KothariAPI::ControllerRegistry.register("profiles", ProfilesController)
  #
  # The server then looks controllers up by this key when routing.
  module ControllerRegistry
    @@controllers = {} of String => KothariAPI::Controller.class

    def self.register(name : String, klass)
      @@controllers[name] = klass
    end

    def self.get(name : String)
      @@controllers[name]?
    end

    # Backwards-compat: older code calls `lookup`, so keep this alias.
    def self.lookup(name : String)
      get(name)
    end
  end
end


