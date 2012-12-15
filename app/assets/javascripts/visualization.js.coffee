root = exports ? this

root.Visualization = class Visualization
  @EVENT_TYPES:
    arrival: "train-platform-arrival"
    departure: "train-platform-departure"
    peopleChange: "people-change"

  constructor: (@events, @acceleration) ->

  run: ->
    @start = Date.now() # in milliseconds
    @_process(@start)

  _process: (now) =>
    @simulationTime = (Date.now() - @start) * @acceleration / 1000.0 # in seconds

    while @events.length > 0 && @events[0].at <= @simulationTime
      event = @events.shift()
      switch event.type
        when Visualization.EVENT_TYPES.arrival then @_onTrainArrival(event.data)
        when Visualization.EVENT_TYPES.departure then @_onTrainDeparture(event.data)
        else @_onPeopleChange(event.data)

    if @events.length > 0
      @_requestAnimationFrame(@_process)

  _requestAnimationFrame: (callback) ->
    @animationFrame ||= window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.msRequestAnimationFrame
    @animationFrame.call(window, callback) # requestAnimationFrame has to be run in the context of window

  _onTrainArrival: (data) ->
    console.log("train-arrival")

  _onTrainDeparture: (data) ->
    console.log("train-departure")

  _onPeopleChange: (data) ->
    console.log("people-change")