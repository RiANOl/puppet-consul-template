require 'json'

Puppet::Functions.create_function(:'consul_template::hcl') do
  # Converts unsorted hash to HCL string making sure the keys are sorted.
  # @param [Hash] unsorted hash
  # @param [Integer] indent
  # @return [String] HCL string

  dispatch :dump do
    param 'Hash', :unsorted_hash
    optional_param 'Integer', :indent
  end

  def dump(obj, indent = 4)
    obj.sort_by { |key, val| key }.map do |key, val|
      generate(val, key, indent, 0)
    end.join("\n") + "\n"
  end

  def generate(obj, prefix = nil, indent = 4, level = 0)
    indent_string = ' ' * indent * level

    if obj.is_a? Hash
      "#{indent_string}#{prefix} {\n" +
        obj.sort_by { |key, val| key }.map do |key, val|
          "#{generate(val, key, indent, level + 1)}"
        end.join("\n") +
        "\n#{indent_string}}"
    elsif obj.is_a? Array and obj.first.is_a? Hash
      obj.map do |val|
        "#{generate(val, prefix, indent, level)}"
      end.join("\n")
    else
      "#{indent_string}#{prefix} = #{generate_oneline(obj)}"
    end
  end

  def generate_oneline(obj)
    if obj.is_a? Hash
      "{ " +
        obj.map do |key, val|
          "#{generate_oneline(key)}: #{generate_oneline(val)}"
        end.join(', ') +
        " }"
    elsif obj.is_a? Array
      "[" +
        obj.map do |val|
          generate_oneline(val)
        end.join(', ') +
        "]"
    else
      obj = nil if obj == :undef
      JSON.dump(obj)
    end
  end
end
