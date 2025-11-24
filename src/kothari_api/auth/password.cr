require "openssl"
require "random"

module KothariAPI
  module Auth
    # Simple password hashing helper using salted SHA-256 with an
    # application-wide pepper. This keeps everything in Crystal/OpenSSL
    # without introducing extra shards, while still being much safer
    # than storing raw passwords.
    module Password
      PEPPER = ENV["KOTHARI_PEPPER"]? || "change-me-in-production"

      # Hash a raw password into "salt$hash" form.
      def self.hash(raw : String) : String
        salt_bytes = Random::Secure.random_bytes(16)
        salt = salt_bytes.hexstring

        digest = OpenSSL::Digest.new("sha256")
        digest.update(salt)
        digest.update(raw)
        digest.update(PEPPER)
        hash = digest.final.hexstring

        "#{salt}$#{hash}"
      end

      # Verify a raw password against a stored "salt$hash" digest.
      def self.verify(raw : String, digest : String) : Bool
        parts = digest.split('$', 2)
        return false unless parts.size == 2
        salt, stored_hash = parts

        d = OpenSSL::Digest.new("sha256")
        d.update(salt)
        d.update(raw)
        d.update(PEPPER)
        candidate = d.final.hexstring

        secure_compare(stored_hash, candidate)
      end

      # Constant-time string comparison to avoid timing leaks.
      def self.secure_compare(a : String, b : String) : Bool
        return false unless a.bytesize == b.bytesize
        result = 0
        a.bytes.zip(b.bytes) do |x, y|
          result |= x ^ y
        end
        result == 0
      end

      # Mixin for models that need password behavior.
      #
      # Usage:
      #   class User < KothariAPI::Model
      #     include KothariAPI::Auth::Password
      #   end
      module InstanceMethods
        property password_digest : String?

        def password=(raw : String)
          @password_digest = KothariAPI::Auth::Password.hash(raw)
        end

        def authenticate(raw : String) : Bool
          return false unless digest = @password_digest
          KothariAPI::Auth::Password.verify(raw, digest)
        end
      end

      macro included
        include KothariAPI::Auth::Password::InstanceMethods
      end
    end
  end
end


