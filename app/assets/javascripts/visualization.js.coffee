root = exports ? this

root.Visualization = class Visualization
  @EVENT_TYPES:
    arrival: "train-semaphore-departure"
    departure: "train-platform-departure"
    peopleChange: "people-change"
    waitingTrainsChange: "waiting-trains-change"
    trainChange: "train-change"

  # in milliseconds
  @VISIBLE_TIME:
    message: 1500
    delay: 1000

  constructor: (@events, @acceleration) ->
    @objects = {}
    @countObjects = {}
    @clockObjects = []
    @_cacheInfrastructure()

  run: ->
    @startSimulationTime = 0
    @resume(@acceleration)

  resume: (acceleration) ->
    @acceleration = acceleration
    @running = true
    @start = Date.now() # in milliseconds
    @_process(@start)

  pause: ->
    @start = Date.now()
    @startSimulationTime = @simulationTime
    @running = false

  _process: (now) =>
    @simulationTime = @startSimulationTime + (Date.now() - @start) * @acceleration / 1000.0 # in seconds
    @_updateClock()

    while @events.length > 0 && @events[0].at <= @simulationTime
      event = @events.shift()
      switch event.type
        when Visualization.EVENT_TYPES.arrival then @_onTrainArrival(event.data)
        when Visualization.EVENT_TYPES.departure then @_onTrainDeparture(event.data)
        when Visualization.EVENT_TYPES.waitingTrainsChange then @_onWaitingTrainsChange(event.data)
        when Visualization.EVENT_TYPES.trainChange then @_onTrainChange(event.data)
        else @_onPeopleChange(event.data)

    if @events.length > 0
      @_requestAnimationFrame(@_process) if @running
    else
      @_clearCache()

  _requestAnimationFrame: (callback) ->
    @animationFrame ||= window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.msRequestAnimationFrame
    @animationFrame.call(window, callback) # requestAnimationFrame has to be run in the context of window

  _cacheInfrastructure: ->
    $("[id^='cash-desk'], [id^='info-desk'], [id^='platform'], [id^='tunnel'], [id^='rail']").each (_, region) =>
      if /count$/.test(region.id)
        @countObjects[region.id] = region
      else
        @objects[region.id] = $(region)

    for id in ["waiting-room-count", "hall-count"]
      @countObjects[id] = document.getElementById(id)

    $("[id^='simulation-time']").each (_, clock) =>
      @clockObjects.push(clock)

    return

  _clearCache: ->
    delete @objects
    delete @countObjects
    delete @clockObjects

  _updateClock: ->
    time = @simulationTime
    hours = Math.floor(time / 3600.0)
    time -= hours * 3600
    minutes = Math.floor(time / 60.0)
    time -= minutes * 60
    seconds = Math.floor(time)

    hours = "0#{hours}" if hours < 10
    minutes = "0#{minutes}" if minutes < 10
    seconds = "0#{seconds}" if seconds < 10

    clock.innerText = "#{hours}:#{minutes}:#{seconds}" for clock in @clockObjects

  _onTrainArrival: (data) ->
    delayed = Math.round((data.delay.external + data.delay.semaphore) / 60.0) > 0
    railId = "rail-#{data.platform}-#{data.rail}"
    $rail = @objects[railId]

    $train = @_buildTrain $.extend({ delayed: delayed, direction: 'right' }, data)
    $rail.append($train)
    @objects[data.train] = $train
    @countObjects["#{data.train}-count"] = document.getElementById("#{data.train}-count")

    @_animateTrainArrival($train, data)
    @_animateTrainDelay(@objects["#{railId}-delay"], { total: data.delay.semaphore + data.delay.external, external: data.delay.external })

  _onTrainDeparture: (data) ->
    $train = @objects[data.train]
    railId = $train.parent().attr('id')
    $delay = @objects["#{railId}-delay"]
    data.delay.total = data.delay.internal + data.delay.external

    @_animateTrainDelay($delay, data.delay)

    @_animateTrainDeparture $train, data, =>
      delete @objects[data.train]
      delete @countObjects["#{data.train}-count"]
      $train.remove()

  _onPeopleChange: (data) ->
    @countObjects["#{data.region}-count"].innerText = data.count

  _onTrainChange: (data) ->
    $message = @_buildMessage($.extend({}, data, { delay: Math.round(data.delay / 60.0) }))
    $message.hide().appendTo($("#messages")).fadeIn().delay(Visualization.VISIBLE_TIME.message).fadeOut()

  _onWaitingTrainsChange: (data) ->
    @countObjects["rail-#{data.platform}-#{data.rail}-waiting-count"].innerText = data.count

    if data.count > 0
      @objects["rail-#{data.platform}-#{data.rail}-waiting"].removeClass('none')
    else
      @objects["rail-#{data.platform}-#{data.rail}-waiting"].addClass('none')

  _buildTrain: (data) ->
    @trainTemplate ||= _.template """
      <div class="train <% if (delayed) { %><%= "delayed" %><% } %> arrival to-<%= direction %>" id="<%= train %>">
        <header class="locomotive">
          <h3>
            <span class="to"><%= to %></span>
            <span class="from"><%= from %></span>
          </h3>
        </header>
        <ul class="units">
          <li>
            <span class="icon-user" id="<%= train %>-count"><%= count %></span>
          </li>
        </ul>
      </div>
    """
    return $(@trainTemplate(data))

  _buildMessage: (data) ->
    @messageTemplate ||= _.template """
      <li>
        <span class="train">
          <%= scheduledAt %> | <%= from %> to <%= to %>
        </span>
        <% if(!!delay) { %>
          <span class="delay"><%= delay %></span>
        <% } %>
        <span class="platform">
          <span class="new"><%= platform.new %></span>
          <% if(platform.new != platform.old) { %>
            <span class="old"><%= platform.old %></span>
          <% } %>
        </span>
      </li>
    """
    return $(@messageTemplate(data))

  _animateTrainArrival: ($train, data) ->
    @_setAnimationDuration($train, Math.round(data.duration * 1000.0 / @acceleration) + 'ms')
    setTimeout =>
      $train.removeClass('arrival')
    , 1

  _animateTrainDeparture: ($train, data, callback) ->
    realDuration = Math.round(data.duration * 1000.0 / @acceleration)
    @_setAnimationDuration($train, realDuration + 'ms')
    @_bindAnimationEndListener($train, callback, realDuration)

    setTimeout =>
      $train.addClass('departure')
    , 1

  _animateTrainDelay: ($delay, delay) ->
    delayId = $delay.attr('id')
    $total = @objects["#{delayId}-total"]
    $external = @objects["#{delayId}-external"]

    # display delay to minutes
    total = Math.round(delay.total / 60.0)
    external = Math.round(delay.external / 60.0)
    $total.text total
    $external.text external

    if total > 0
      $delay.removeClass('none')
      setTimeout =>
        $delay.addClass('none')
      , Visualization.VISIBLE_TIME.delay
    else
      $delay.addClass('none')

  _setAnimationDuration: ($element, duration) ->
    prefixify "TransitionDuration", (prefixed) ->
      $element.css(prefixed, duration)
    , 'css'

  _bindAnimationEndListener: ($element, listener, duration) ->
    # fallback
    setTimeout listener, duration
    return

    prefixify "AnimationEnd", (prefixed) ->
      $element.bind(prefixed, listener)