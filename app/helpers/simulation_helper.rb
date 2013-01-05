module SimulationHelper
  def hidden_attribute_range_fields(form_builder, attribute_name)
    "".tap do |s|
      s << form_builder.hidden_field("min_#{attribute_name}".to_sym)
      s << form_builder.hidden_field("max_#{attribute_name}".to_sym)
      s << content_tag(:span, nil, id: "#{attribute_name}_label", class: 'value')
    end.html_safe
  end

  def attribute_range_field(form_builder, attribute_name, options = {})
    range = Simulation::PARAMETERS[attribute_name][:values]
    values = %w[min max].map do |prefix|
      form_builder.object.send("#{prefix}_#{attribute_name}")
    end

    render partial: "/shared/range", locals: {
      values: values,
      range: range,
      attribute: attribute_name,
      options: options
    }
  end

  def attribute_clock_range_field(form_builder, attribute_name, options = {})
    render partial: "/shared/clock_range", locals: {
      f: form_builder,
      attribute: attribute_name
    }
  end

  def attribute_field(form_builder, attribute_name, options = {})
    range = Simulation::PARAMETERS[attribute_name][:values]
    form_builder.text_field attribute_name, class: options[:class], data: { min: range.first, max: range.last }
  end
end