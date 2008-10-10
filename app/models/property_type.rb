class PropertyType < ActiveRecord::Base

  class NoPropertyClass < StandardError; end
  class NotDescriptorType < StandardError; end

  belongs_to :property_class

  has_many :properties

  validates_presence_of :name, :property_class_id

  def self.browse &block
    options = { :order => "priority asc, name asc",
                :conditions => [ "browsable = true" ] }
    if block
      ( self.find :all, options ).each &block
    else
      ( self.find :all, options )
    end
  end

  def self.descriptor_types
    find :all, :order => "pts.priority asc, pts.name asc",
               :select => "pts.*",
               :joins => "pts, property_classes pcs",
               :conditions => "property_class_id = pcs.id and " +
                              "range = 'descriptor_value'"
  end

  def descriptor_values
    raise NotDescriptorType.new( property_class_id ) unless 
      property_class.range == "descriptor_value"
    property_class.values self
  end

  def values options = {}
    raise NoPropertyClass.new( property_class_id ) unless property_class
    return property_class.values( self, options )
  end

  def field
    property_class and property_class.field
  end

  def validate_value string
    raise NoPropertyClass.new( property_class_id ) unless property_class
    property_class.validate_value string
  end

  def translate_value string
    raise NoPropertyClass.new( property_class_id ) unless property_class
    property_class.translate_value string
  end

  def retrieve_value property
    raise NoPropertyClass.new( property_class_id ) unless property_class
    property_class.retrieve_value property
  end

  def retrieve_priority property
    raise NoPropertyClass.new( property_class_id ) unless property_class
    property_class.retrieve_priority property
  end

  def self.validate_object object
    validate_required( object ) and validate_arity( object )
  end

  def self.validate_required object

    okay = true

    required_classes = PropertyClass.find_all_by_optional false

    required_types =
      PropertyType.find_all_by_property_class_id required_classes.map( &:id )

    required_types.each do |rt|
      if !object.properties.detect { |p| p.property_type_id == rt.id }
        object.errors.add_to_base "property #{rt.name} required"
        okay = false
      end
    end

    return okay

  end

  def self.validate_arity object

    okay = true

    singular_classes = PropertyClass.find_all_by_multivalued false

    singular_types =
      PropertyType.find_all_by_property_class_id singular_classes.map( &:id )

    singular_types.each do |st|
      # could terminate early ...
      count = object.properties.inject(0) do |count,p|
        count + ( p.property_type_id == st.id ? 1 : 0 )
      end
      if count > 1
        object.errors.add_to_base "property #{st.name} has multiple values"
        okay = false
      end
    end

    return okay

  end

end
