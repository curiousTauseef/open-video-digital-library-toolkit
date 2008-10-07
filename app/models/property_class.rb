class PropertyClass < ActiveRecord::Base

  RANGE_MAP = {

    "string" => { :field => :string_value,
                  :validate  => lambda { |v| validate_string( v ) },
                  :translate => lambda { |v| translate_string(v) },
                  :retrieve  => lambda { |p| retrieve_string(p) } },

    "date" => { :field => :date_value,
                :validate  => lambda { |v| validate_date( v ) },
                :translate => lambda { |v| translate_date(v) },
                :retrieve  => lambda { |p| retrieve_date(p) } },

  }

  validates_presence_of :name
  validates_inclusion_of :multivalued, :optional, :in => [ true, false ]
  validates_inclusion_of :range, :in => RANGE_MAP.keys

  class NoRangeClass < StandardError; end

  def field
    lambdas = RANGE_MAP[range]
    lambdas and lambdas[:field]
  end

  def validate_value property
    lambdas = RANGE_MAP[range]
    raise NoRangeClass.new( range ) if not lambdas
    lambdas[:validate] ? lambdas[:validate].call( property ) : true
  end

  def translate_value property
    lambdas = RANGE_MAP[range]
    raise NoRangeClass.new( range ) if not lambdas
    lambdas[:translate] ? lambdas[:translate].call( property ) : true
  end

  def retrieve_value property
    lambdas = RANGE_MAP[range]
    raise NoRangeClass.new( range ) if not lambdas
    lambdas[:retrieve].call( property ).to_s
  end

  class << self

    NIL_STRING = ""
    NIL_INTEGER = 0
    NIL_DATE = Date.new

    def fields
      [ :date_value, :string_value, :date_value ]
    end

    def default property
      property.string_value = NIL_STRING if property.string_value.nil?
      property.date_value = NIL_DATE if property.date_value.nil?
      property.integer_value = NIL_INTEGER if property.integer_value.nil?
    end

    private

    def validate_not_blank property
      if property.value.blank?
        property.errors.add :value, "cannot be blank"
        return false
      end
      true
    end      

    def validate_string property
      validate_not_blank property
    end

    def translate_string property
      property.string_value = property.value
    end

    def retrieve_string property
      property.string_value
    end

    def validate_date property

      return false if !validate_not_blank( property )

      begin
        Date.parse( property.value )
        return true
      rescue ArgumentError => ae
        property.errors.add :value, ae.to_s
        return false
      end

    end
      
    def translate_date property
      property.date_value = Date.parse( property.value )
    end
      
    def retrieve_date property
      property.date_value == NIL_DATE ? nil : property.date_value.to_s
    end

  end

end