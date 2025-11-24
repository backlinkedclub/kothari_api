require "json"
require "db"
require "./validations"

module KothariAPI
  class Model
    include JSON::Serializable
    include Validations

    # Default table method so the base class compiles; subclasses
    # are expected to override this by calling `table "name"`.
    def self.table
      raise "table not defined for #{self}"
    end

    # Store the table name using macro
    macro table(name)
      @@table = {{name}}
      def self.table
        @@table
      end
    end

    # JSON serialization - serialize all instance variables
    def to_json(json : JSON::Builder)
      json.object do
        {% begin %}
          {% ivars = @type.instance_vars %}
          {% for ivar in ivars %}
            json.field({{ivar.name.stringify}}, @{{ivar.name.id}})
          {% end %}
        {% end %}
      end
    end

    # CREATE a record
    def self.create(**fields)
      now = Time.utc.to_s("%Y-%m-%d %H:%M:%S")
      
      # Extract keys and values, preserving original types
      all_keys = fields.keys.map(&.to_s)
      
      # Convert values to Array(DB::Any) to preserve types (String, Int32, Bool, etc.)
      all_values = [] of ::DB::Any
      fields.values.each do |val|
        all_values << val.as(::DB::Any)
      end
      
      # Build SQL
      keys = all_keys.join(", ")
      placeholders = all_keys.map { "?" }.join(", ")

      sql = "INSERT INTO #{self.table} (#{keys}) VALUES (#{placeholders})"
      
      # Use exec with args parameter to properly pass the array
      result = KothariAPI::DB.conn.exec(sql, args: all_values)

      id = result.last_insert_id.to_i
      find(id)
    end

    # FIND by id
    def self.find(id : Int)
      sql = "SELECT * FROM #{self.table} WHERE id = ? LIMIT 1"
      record = nil

      KothariAPI::DB.conn.query(sql, id) do |rs|
        if rs.move_next
          record = new_from_row(rs)
        end
      end

      record
    end

    # ALL records
    def self.all
      sql = "SELECT * FROM #{self.table}"
      results = [] of self

      KothariAPI::DB.conn.query(sql) do |rs|
        while rs.move_next
          results << new_from_row(rs)
        end
      end

      results
    end

    # WHERE
    def self.where(condition : String)
      sql = "SELECT * FROM #{self.table} WHERE #{condition}"
      results = [] of self

      KothariAPI::DB.conn.query(sql) do |rs|
        while rs.move_next
          results << new_from_row(rs)
        end
      end

      results
    end

    # FIND_BY - Safe parameterized query
    def self.find_by(column : String, value)
      sql = "SELECT * FROM #{self.table} WHERE #{column} = ? LIMIT 1"
      record = nil

      KothariAPI::DB.conn.query(sql, value) do |rs|
        if rs.move_next
          record = new_from_row(rs)
        end
      end

      record
    end

    # Convert the current row in a `DB::ResultSet` into a model
    # instance by reading columns in order. The first column is `id`,
    # and then we read each instance variable in declaration order.
    def self.new_from_row(rs)
      # Read all instance variable values in order and instantiate.
      # Filter out JSON::Serializable instance variables like @json_unmapped.
      #
      # IMPORTANT: For the base `KothariAPI::Model` (which has no real
      # instance vars), we **don't** try to call `new` with zero args,
      # because the only constructor there is `new(JSON::PullParser)`.
      # In that case we raise a clear error instead of a compile-time
      # macro failure.
      {% begin %}
        {% ivars = @type.instance_vars.reject { |ivar|
          name = ivar.name.stringify
          name == "json_unmapped" || ivar.type.stringify.includes?("Hash(String, Array(String))")
        } %}

        {% if ivars.size == 0 %}
          # This happens for the abstract/base model type. Any concrete
          # application model should have at least one instance var.
          raise "new_from_row called on {{@type}} which has no instance vars; make sure you're using a concrete model subclass"
        {% else %}
          # Build read statements for each instance variable with proper type casting
          # The first column in the database is id, then all other fields
          # But in the constructor, id is last (since it's optional)
          {% id_ivar = ivars.find { |ivar| ivar.name.stringify == "id" } %}
          {% other_ivars = ivars.reject { |ivar| ivar.name.stringify == "id" } %}
          {% if id_ivar %}
            {% if id_ivar.type.stringify.includes?("Int64?") %}
              ; id_val : Int64? = rs.read(Int64)
            {% elsif id_ivar.type.stringify.includes?("Int32?") %}
              ; id_val : Int32? = rs.read(Int64).to_i32
            {% elsif id_ivar.type.stringify.includes?("Int64") %}
              ; id_val = rs.read(Int64)
            {% else %}
              ; id_val = rs.read(Int64).as({{id_ivar.type}})
            {% end %}
          {% end %}
          {% for ivar, index in other_ivars %}
            {% if index == 0 %}
              val{{index}} = rs.read({{ivar.type}})
            {% else %}
              ; val{{index}} = rs.read({{ivar.type}})
            {% end %}
          {% end %}
          {% if id_ivar %}
            ; new({% for ivar, index in other_ivars %}{% if index > 0 %}, {% end %}val{{index}}{% end %}{% if other_ivars.size > 0 %}, {% end %}id_val)
          {% else %}
            ; new({% for ivar, index in other_ivars %}{% if index > 0 %}, {% end %}val{{index}}{% end %})
          {% end %}
        {% end %}
      {% end %}
    end
  end
end
