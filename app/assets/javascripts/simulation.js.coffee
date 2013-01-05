root = exports ? this

# requires jQuery
root.Simulation =
  SIZING_SCALE: 5

  knob:
    colors:
      disabled:
        normal:
          bgColor: "rgb(255, 255, 255)"
          fgColor: "rgb(141, 141, 141)"
        danger:
          bgColor: "rgb(255, 255, 255)"
          fgColor: "rgb(141, 141, 141)"
      enabled:
        normal:
          bgColor: "rgb(255, 255, 255)"
          fgColor: "rgb(31, 184, 208)"
        danger:
          bgColor: "rgb(255, 255, 255)"
          fgColor: "rgb(159, 63, 95)"
    size:
      toolbar:
        width: 50
        height: 50
        thickness: 0.25
      small:
        width: 80
        height: 80
      normal:
        width: 120
        height: 120
      big:
        width: 160
        height: 160

  chart:
    colors: ["rgb(31, 184, 208)"]
    chart:
      animation: false
      backgroundColor: "rgba(255, 255, 255, 1)"
    yAxis:
      title:
        style:
          color: "rgb(31, 184, 208)"
      gridLineColor: "rgba(141, 141, 141, 0.1)"
    xAxis:
      lineColor: "rgba(141, 141, 141, 0.1)"
      title:
        style:
          color: "rgb(31, 184, 208)"
    plotOptions:
      series:
        cursor: 'ns-resize'
        stickyTracking: false
        shadow: false
    tooltip:
      yDecimals: 1
    legend:
      enabled: false

  disabledChart:
    colors: ["rgb(141, 141, 141)"]
    plotOptions:
      series:
        cursor: 'auto'

  callbacks:
    play: ->
      false
    pause: ->
      false
    submit: ->
      false
  state: 'pause'

  initFields: (options) ->
    options ||= {}
    Simulation._initKnob(options)
    Simulation._initLabelRangeWithFields({ disabled: !!options.disabled, prefix: "simulation_" })
    Simulation._initClockRangeWithFields({ disabled: !!options.disabled, prefix: "simulation_" })
    Simulation._initResizableFields({ disabled: !!options.disabled, prefix: "simulation_" })

  initVisitorComingChart: (options, isDisabled) ->
    @visitorComingChart = Simulation._initChart(options, isDisabled)

  initCompanionCountChart: (options, isDisabled) ->
    @companionCountChart = Simulation._initChart(options, isDisabled)

  initWalkingSpeedChart: (options, isDisabled) ->
    @walkingSpeedChart = Simulation._initChart(options, isDisabled)
    Simulation._refreshMaxWalkingSpeed()

  getVisitorComingDistribution: ->
    @_getChartYSeries(@visitorComingChart, 0)

  getCompanionCountDistribution: ->
    @_getChartYSeries(@companionCountChart, 0)

  getWalkingSpeedDistribution: ->
    @_getChartYSeries(@walkingSpeedChart, 0)

  initSettingsNavigation: ->
    @settingsPageIndex = 0

    $("#settings nav .section > a").click (event) ->
      event.preventDefault()
      $li = $(this).parent()
      $li.trigger('section:open')
      $li.find('.active').eq(0).trigger('page:open')

    $("#settings nav .page > a").click (event) ->
      event.preventDefault()
      $li = $(this).parent()
      $li.trigger('page:open')

    $("#settings nav .section").bind 'section:open', ->
      $li = $(this)
      unless $li.hasClass('active')
        $li.addClass('active').siblings('.active').removeClass('active')

    $("#settings nav .page").each (i, li) ->
      $(li).bind 'page:open', ()->
        Simulation.settingsPageIndex = i
        $li = $(this)
        $li.parents('li').trigger('section:open')
        unless $li.hasClass('active')
          $(this).addClass('active').siblings('.active').removeClass('active')
        $(".settings-container > ul").css('left', -i*100 + '%')

    $(".settings .actions .next").click (event) ->
      event.preventDefault()
      Simulation.settingsPageIndex++
      $li = $("#settings nav .page").eq(Simulation.settingsPageIndex)
      if $li.size() == 0
        $form = $(this).parents('form')
        Simulation.trigger('submit', $form)
        Simulation.settingsPageIndex--
      else
        $li.trigger('page:open')

    $(".settings .actions .prev").click (event) ->
      event.preventDefault()
      unless Simulation.settingsPageIndex <= 0
        Simulation.settingsPageIndex--
        $li = $("#settings nav .page").eq(Simulation.settingsPageIndex)
        $li.trigger('page:open')

    $("#settings nav .page").eq(Simulation.settingsPageIndex).trigger('page:open')

  getResult: (path, options) ->
    options ||= {}
    interval = setInterval ->
      $.post path, (data, _, xhr) ->
        if xhr.status == 202 # still processing
          options.process(data) if typeof options.process == "function"
        else
          clearInterval(interval)
          options.success(data) if typeof options.success == "function"
      , "json"
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

  getAcceleration: ->
    parseInt($("#acceleration").val())

  togglePlayback: ->
    if @state == "pause"
      @trigger('play')
    else
      @trigger('pause')

  trigger: (event, argument) ->
    @callbacks[event](argument) if typeof @callbacks[event] == "function"
    @state = event

  bind: (event, callback) ->
    @callbacks[event] = callback

  # changing value on the first knob changes value on the another
  bindKnobsTogether: ($element1, $element2) ->
    $element1.trigger 'configure',
      change: (value) ->
        $element2.val(value).trigger('change')

    $element2.trigger 'configure',
      change: (value) ->
        $element1.val(value).trigger('change')

  disableKnob: ($elements) ->
    colors = Simulation.knob.colors.disabled

    $elements.each (_, element) ->
      elementColors = if $(element).hasClass('knob-danger') then colors.danger else colors.normal
      $(element).trigger('configure', { readOnly: true, fgColor: elementColors.fgColor })

  enableKnob: ($elements) ->
    colors = Simulation.knob.colors.enabled

    $elements.each (_, element) ->
      elementColors = if $(element).hasClass('knob-danger') then colors.danger else colors.normal
      $(element).trigger('configure', { readOnly: false, fgColor: elementColors.fgColor })

  _initKnob: (options) ->
    knob = Simulation.knob
    colors = if options.disabled then knob.colors.disabled else knob.colors.enabled

    $(".knob").knob $.extend({ readOnly: options.disabled }, knob.size.normal, colors.normal)
    $(".knob-danger").knob $.extend({ readOnly: options.disabled }, knob.size.normal, colors.danger)
    $(".knob-big").knob $.extend({ readOnly: options.disabled }, knob.size.big, colors.normal)
    $(".knob-small").knob $.extend({ readOnly: options.disabled }, knob.size.small, colors.normal)
    $(".knob-enabled").knob $.extend({ readOnly: false }, knob.size.normal, knob.colors.enabled.normal)
    $(".knob-toolbar").knob $.extend({ readOnly: false, displayInput: false }, knob.size.toolbar, knob.colors.enabled.normal)

  _initChart: (options, isDisabled) ->
    if isDisabled
      options = $.extend(true, {}, Simulation.disabledChart, options)
    new Highcharts.Chart($.extend(true, {}, Simulation.chart, options))

  _initResizableFields: (options) ->
    $('.resizable').each (_, resizable) ->
      $length = $('#' + this.id + '_length')
      $width = $('#' + this.id + '_width')
      $time = $('#' + this.id + '_walking_time')

      updateTime = (length) ->
        if Simulation.maxWalkingSpeed?
          # 3.6 is there because maxWalkingSpeed is in km/h and we need it in m/s
          $time.text(Number(length / Simulation.maxWalkingSpeed * 3.6).toFixed(1) + ' s')

      $(this).resizable({
        disabled: options.disabled
        minHeight: parseInt($length.attr('data-min')) * Simulation.SIZING_SCALE
        minWidth: parseInt($width.attr('data-min')) * Simulation.SIZING_SCALE
        maxHeight: parseInt($length.attr('data-max')) * Simulation.SIZING_SCALE
        maxWidth: parseInt($width.attr('data-max')) * Simulation.SIZING_SCALE
        aspectRatio: !!$(this).attr('data-preserve-ratio')
        handles: 's, e, se'
        resize: (event, ui) ->
          $length.val(Number(ui.size.height / Simulation.SIZING_SCALE).toFixed(1))
          $width.val(Number(ui.size.width / Simulation.SIZING_SCALE).toFixed(1))
          updateTime(ui.size.height / Simulation.SIZING_SCALE)
      }).bind('hover', ->
        Simulation._refreshMaxWalkingSpeed()
        updateTime(parseInt($length.val()))
      ).css({ width: parseInt($length.val()) * Simulation.SIZING_SCALE, height: parseInt($width.val()) * Simulation.SIZING_SCALE })

  _initLabelRangeWithFields: (options) ->
    $("form .slider:not(.time-range)").each (_, slider) ->
      $slider = $(slider)
      $label = $("#" + slider.id + "_label")
      $inputs = $("#" + options.prefix + "min_" + slider.id + ", #" + options.prefix + "max_" + slider.id)

      rangeOptions = Simulation._extractRangeOptions($slider, $inputs)
      $.extend true, rangeOptions, {
        disabled: options.disabled
        slide: (_, ui) ->
          $inputs.eq(0).val(ui.values[0])
          $inputs.eq(1).val(ui.values[1])
          $label.text(ui.values.join(" - "))
      }

      $slider.slider(rangeOptions)
      $label.text(rangeOptions.values.join(" - "))

  _initClockRangeWithFields: (options) ->
    $("form .slider.time-range").each (_, slider) ->
      $slider = $(slider)
      $inputs = $("#" + options.prefix + "min_" + slider.id + ", #" + options.prefix + "max_" + slider.id)
      clock = document.getElementById(slider.id + "_clock")

      # to make slider work in the different direction
      reverseValues = (values) ->
        [60 - values[1], 60 - values[0]]

      rangeOptions = Simulation._extractRangeOptions($slider, $inputs)
      normalValues = rangeOptions.values
      rangeOptions.values = reverseValues(normalValues)

      clockOptions =
        values: normalValues

      if options.disabled
        clockOptions.rangeColor = Simulation.knob.colors.disabled.normal.fgColor
        $(clock).parent().addClass('clock-disabled')

      clockRange = new ClockRange(clock, clockOptions)

      # HACK! sometimes font is missing and it cannot be drawn properly
      setTimeout ->
        clockRange._draw()
      , 10

      $.extend true, rangeOptions, {
        disabled: options.disabled
        slide: (_, ui) ->
          values = reverseValues(ui.values)
          clockRange.setValues(values)
          $inputs.eq(i).val(values[i]) for i in [0..1]
      }

      $slider.slider(rangeOptions)

  _extractRangeOptions: ($slider, $inputs) ->
    extracted =
      min: parseInt($slider.attr('data-min'))
      max: parseInt($slider.attr('data-max'))
      range: true
      values: Simulation._extractInputNumericValues($inputs)
      orientation: $slider.attr('data-orientation')

  _extractInputNumericValues: ($inputs) ->
    values = []
    $inputs.each (_, input) ->
      values.push parseFloat(input.value)
    return values

  _refreshMaxWalkingSpeed: ->
    @maxWalkingSpeed = Math.max.apply(Math.max, @walkingSpeedChart.series[0].yData)

  _getChartYSeries: (chart, seriesNo) ->
    series = chart.series[seriesNo].yData
    (@_round(y, 3) for y in series)

  _round: (number, decimals) ->
    factor = Math.pow(10, decimals)
    Math.round(number * factor) / factor

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