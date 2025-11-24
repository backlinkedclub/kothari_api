# Quick test script to verify auth works
require "./src/kothari_api"
require "http/server"

KothariAPI::DB.connect("test_auth.db")

# Test password hashing
hash1 = KothariAPI::Auth::Password.hash("secret123")
hash2 = KothariAPI::Auth::Password.hash("secret123")
puts "Hash 1: #{hash1[0..20]}..."
puts "Hash 2: #{hash2[0..20]}..."
puts "Verify 1: #{KothariAPI::Auth::Password.verify("secret123", hash1)}"
puts "Verify 2: #{KothariAPI::Auth::Password.verify("wrong", hash1)}"

# Test JWT
token = KothariAPI::Auth::JWTAuth.issue_simple({"email" => "test@example.com"})
puts "Token: #{token[0..30]}..."
payload = KothariAPI::Auth::JWTAuth.decode(token)
puts "Decoded email: #{payload["email"]}"

puts "\n✅ Auth modules work correctly!"

