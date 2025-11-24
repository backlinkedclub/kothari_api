require "file_utils"
require "mime"

module KothariAPI
  module Storage
    # Simple, fast file storage system
    # Stores files in public/uploads directory
    
    @@uploads_path = "public/uploads"
    
    def self.uploads_path
      @@uploads_path
    end
    
    # Save an uploaded file and return the public URL path
    def self.save(file_data : String, filename : String, content_type : String? = nil) : String
      # Ensure uploads directory exists
      FileUtils.mkdir_p(@@uploads_path)
      
      # Generate unique filename to avoid collisions
      ext = File.extname(filename)
      base_name = File.basename(filename, ext)
      unique_name = "#{base_name}_#{Time.utc.to_unix_ms}#{ext}"
      
      # Save file
      file_path = File.join(@@uploads_path, unique_name)
      File.write(file_path, file_data)
      
      # Return public URL path
      "/uploads/#{unique_name}"
    end
    
    # Save file from HTTP::FormData::Part
    def self.save_from_form(form_data : HTTP::FormData::Part) : String
      filename = form_data.filename || "upload_#{Time.utc.to_unix_ms}"
      content = form_data.body.gets_to_end
      content_type = form_data.headers["Content-Type"]? || "application/octet-stream"
      
      save(content, filename, content_type)
    end
    
    # Delete a file by its public URL path
    def self.delete(url_path : String) : Bool
      return false unless url_path.starts_with?("/uploads/")
      
      filename = File.basename(url_path)
      file_path = File.join(@@uploads_path, filename)
      
      if File.exists?(file_path)
        File.delete(file_path)
        true
      else
        false
      end
    end
    
    # Check if file exists
    def self.exists?(url_path : String) : Bool
      return false unless url_path.starts_with?("/uploads/")
      
      filename = File.basename(url_path)
      file_path = File.join(@@uploads_path, filename)
      File.exists?(file_path)
    end
  end
end

