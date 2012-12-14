root = exports ? this

root.Simulation =
  knob:
    colors:
      disabled:
        normal:
          bgColor: "rgb(254, 250, 245)"
          fgColor: "rgb(141, 141, 141)"
        danger:
          bgColor: "rgb(254, 250, 245)"
          fgColor: "rgb(141, 141, 141)"
      enabled:
        normal:
          bgColor: "rgb(254, 250, 245)"
          fgColor: "rgb(31, 184, 208)"
        danger:
          bgColor: "rgb(254, 250, 245)"
          fgColor: "rgb(159, 63, 95)"
    size:
      normal:
        width: 120
        height: 120
      big:
        width: 360
        height: 360

  rangeAttributes: [
    {
      name: "coming_time_span_with_ticket"
      min: 1
      max: 60
    },
    {
      name: "coming_time_span_without_ticket"
      min: 1
      max: 60
    },
    {
      name: "serving_information_time"
      min: 1
      max: 60
    },
    {
      name: "selling_ticket_time"
      min: 1
      max: 60
    },
    {
      name: "arriving_passenger_count"
      min: 0
      max: 1000
    },
    {
      name: "departuring_passenger_count"
      min: 0
      max: 1000
    },
    {
      name: "internal_arrival_time"
      min: 0
      max: 60
    }
  ]

  initFields: (options) ->
    options ||= {}
    Simulation._initKnob(options)
    Simulation._initLabelRangeWithFields(r.name, { min: r.min, max: r.max, disabled: !!options.disabled }, "simulation_") for r in Simulation.rangeAttributes

  getResult: (path, options) ->
    options ||= {}
    interval = setInterval ->
      $.post path, (data, _, xhr) ->
        if xhr.status == 202 # still processing
          options.process(data) if typeof options.process == "function"
        else
          clearInterval(interval)
          options.success(data) if typeof options.success == "function"
    , 1000

  _initKnob: (options) ->
    knob = Simulation.knob
    colors = if options.disabled then knob.colors.disabled else knob.colors.enabled

    $(".knob").knob $.extend({ readOnly: options.disabled }, knob.size.normal, colors.normal)
    $(".knob-danger").knob $.extend({ readOnly: options.disabled }, knob.size.normal, colors.danger)
    $(".knob-big").knob $.extend({ readOnly: options.disabled }, knob.size.big, colors.normal)
    $(".knob-enabled").knob $.extend({ readOnly: false }, knob.size.normal, knob.colors.enabled.normal)

  _initLabelRangeWithFields: (rangeName, rangeOptions, prefix) ->
    $range = $("#" + rangeName)
    $label = $("#" + rangeName + "_label")
    $inputs = $("#" + prefix + "min_" + rangeName + ", #" + prefix + "max_" + rangeName)
    values = Simulation._extractInputNumericValues($inputs)
    $.extend(rangeOptions, {
      range: true
      values: values
      slide: (_, ui) ->
        $inputs.eq(0).val(ui.values[0])
        $inputs.eq(1).val(ui.values[1])
        $label.text(ui.values.join(" - "))
    })

    $range.slider(rangeOptions)
    $label.text(values.join(" - "))

  _extractInputNumericValues: ($inputs) ->
    values = []
    $inputs.each (_, input) ->
      values.push parseFloat(input.value)
    return values