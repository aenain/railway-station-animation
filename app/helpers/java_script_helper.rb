module JavaScriptHelper
  # Works like Rails built-in +options_for_javascript+, but unlike
  # it allows +options+ to be nested hash or to contain array values
  # (as a side effect also allows +options+ to be a scalar value).
  # It is also possible to eval snippet of javascript to obtain value for
  # an option like this:
  #
  #   nested_options_for_javascript(:color => lambda { "someJavaScriptFunction()" })
  #
  def nested_options_for_javascript(options)
    if options.is_a?(Hash)
      new_options = {}
      options.each do |k, v|
        new_options["'#{k.to_s.camelize(:lower)}'"] = nested_options_for_javascript(v)
      end
      options_for_javascript(new_options)
    elsif options.is_a?(Array)
      "[#{options.collect { |v| nested_options_for_javascript(v) }.join(',')}]"
    elsif options.is_a?(Numeric)
      options.to_s
    elsif options.is_a?(String)
      array_or_string_for_javascript(escape_javascript(options))
    elsif options.is_a?(Proc)
      options.call
    elsif options.is_a?(Time)
      time = options.dup.utc
      "Date.UTC(#{time.year}, #{time.month - 1}, #{time.day}, #{time.hour}, #{time.min}, #{time.sec})"
    elsif options.is_a?(Date)
      "(new Date(#{options.year}, #{options.month}, #{options.day}))"
    elsif options == false
      "false"
    elsif options == true
      "true"
    elsif options.nil?
      "null"
    end
  end
end