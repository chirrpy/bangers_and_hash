module AttributeHashAccessors
  module ClassMethods
    def hash_attr_accessors(*attrs)
      attrs.each do |method|
        method_name = method.to_s

        define_method(method.to_sym) do
          @attributes[method_name]
        end

        define_method("#{method_name}=".to_sym) do |value|
          send("#{method_name}_will_change!") unless @attributes[method_name] == value
          @attributes[method_name] = value
        end
      end

      define_method(:attributes) do
        ActiveSupport::HashWithIndifferentAccess.new.tap do |hash|
          attrs.each do |attr|
            attr_name = attr.to_s

            hash[attr_name] = @attributes[attr_name]
          end
        end
      end

      self.class_eval do
        define_attribute_methods attrs
      end
    end
  end

  def self.included(base)
    base.send(:include, ActiveModel::AttributeMethods)
    base.send(:include, ActiveModel::Dirty)

    base.extend ClassMethods
  end

  def initialize(attrs = {})
    @attributes     = ActiveSupport::HashWithIndifferentAccess.new
    self.attributes = attrs
  end

  ###
  # TODO: Raise error if an attrubute passed in does not exist in the list
  # of acceptable attributes
  #
  def attributes=(attrs = {})
    attrs           = attrs.with_indifferent_access
    safe_attributes = attrs.slice *attributes.keys

    @attributes.merge! safe_attributes
  end

  def attributes
    ActiveSupport::HashWithIndifferentAccess.new
  end
end
