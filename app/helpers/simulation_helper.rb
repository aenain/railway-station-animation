module SimulationHelper
  def hidden_attribute_range_fields(form_builder, attribute_name)
    "".tap do |s|
      s << form_builder.hidden_field("min_#{attribute_name}".to_sym)
      s << form_builder.hidden_field("max_#{attribute_name}".to_sym)
      s << content_tag(:span, nil, id: "#{attribute_name}_label", class: 'value')
    end.html_safe
  end
end