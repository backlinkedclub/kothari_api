require "json"

module KothariAPI
  module Validations
    @errors = {} of String => Array(String)

    def errors
      @errors
    end

    def valid?
      @errors.clear
      validate
      @errors.empty?
    end

    def errors_full_messages : Array(String)
      messages = [] of String
      @errors.each do |field, field_errors|
        field_errors.each do |error|
          messages << "#{field} #{error}"
        end
      end
      messages
    end

    def add_error(field : String, message : String)
      @errors[field] ||= [] of String
      @errors[field] << message
    end

    # Override in models
    def validate
      # Subclasses implement
    end

    # Validation helpers
    macro validates(field, presence = false, length = nil)
      def validate
        {% if presence %}
          if @{{field.id}}.nil? || (@{{field.id}}.is_a?(String) && @{{field.id}}.empty?)
            add_error({{field.stringify}}, "can't be blank")
          end
        {% end %}
        {% if length %}
          {% if length[:minimum] %}
            if @{{field.id}}.is_a?(String) && @{{field.id}}.size < {{length[:minimum]}}
              add_error({{field.stringify}}, "is too short (minimum is {{length[:minimum]}} characters)")
            end
          {% end %}
          {% if length[:maximum] %}
            if @{{field.id}}.is_a?(String) && @{{field.id}}.size > {{length[:maximum]}}
              add_error({{field.stringify}}, "is too long (maximum is {{length[:maximum]}} characters)")
            end
          {% end %}
        {% end %}
        super
      end
    end
  end
end




