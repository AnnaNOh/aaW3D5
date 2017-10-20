class AttrAccessorObject

  def self.my_attr_accessor(*names)
    names.each do |name|

      define_method(name) do
        getter_name = "@" + name.to_s
        instance_variable_get(getter_name)
      end

      setter_method_name = name.to_s + "="
      define_method(setter_method_name) do |value|
        setter_name = "@" + name.to_s
        instance_variable_set(setter_name, value)
      end

    end
  end
end
