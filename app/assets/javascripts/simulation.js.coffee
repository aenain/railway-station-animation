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

  initSummary: (data) ->
    @_initSummaryPeople(data)
    @_initSummaryCashDesks(data)
    @_initSummaryInformation(data)
    @_initSummaryTrains(data)

  # allowed precisions: "minutes", "seconds"
  prettyTime: (seconds, precision) ->
    formatted = ""
    if seconds > 3600
      hours = Math.floor(seconds / 3600)
      seconds -= hours * 3600
      formatted += hours + " hours "
    if precision == "minutes"
      formatted += Math.round(seconds / 60) + " min "
    else
      if seconds > 60
        minutes = Math.floor(seconds / 60)
        seconds -= minutes * 60
        formatted += minutes + " min "
      if seconds > 0
        formatted += seconds + " sec"
    formatted

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

  _initSummaryPeople: (data) ->
    totalPeople = data.passengers.arriving + data.passengers.departuring + data.companions + data.visitors

    $("#summary").append @_buildSummarySection({
      title: 'People'
      data: [
        { description: 'Arriving passengers', value: data.passengers.arriving },
        { description: 'Departuring passengers', value: data.passengers.departuring },
        { description: 'Companions', value: data.companions },
        { description: 'Visitors', value: data.visitors },
        { description: 'Total', value: totalPeople }
      ]
    })

  _initSummaryCashDesks: (data) ->
    $("#summary").append @_buildSummarySection({
      title: 'Cash Desks'
      data: [
        { description: 'Sold tickets', value: data.cashDesks.soldTickets },
        { description: 'Average waiting time', value: @prettyTime(data.cashDesks.averageWaitingTime, "seconds") }
      ]
    })

  _initSummaryInformation: (data) ->
    $("#summary").append @_buildSummarySection({
      title: 'Information'
      data: [
        { description: 'Served informations', value: data.infoDesks.servedInformations },
        { description: 'Complaints', value: data.infoDesks.complaints },
        { description: 'Average waiting time', value: @prettyTime(data.infoDesks.averageWaitingTime, "seconds") }
      ]
    })

  _initSummaryTrains: (data) ->
    $("#summary").append @_buildSummarySection({
      title: 'Trains'
      data: [
        { description: 'Average external delay', value: @prettyTime(data.trains.delay.average.external, "minutes") },
        { description: 'Average semaphore delay', value: @prettyTime(data.trains.delay.average.semaphore, "minutes") },
        { description: 'Average platform delay', value: @prettyTime(data.trains.delay.average.platform, "minutes") },
        { description: 'Platform changes', value: data.trains.platformChanges },
        { description: 'Total', value: data.trains.count }
      ]
    })

  _buildSummarySection: (options) ->
    @summarySection ||= _.template """
      <div class="container">
        <h3><%= title %></h3>
        <table>
          <% _.each(data, function(row) { %>
            <tr><td><%= row.description %></td><td><%= row.value %></td></tr>
          <% }) %>
        </table>
      </div>
    """

    $(@summarySection(options))