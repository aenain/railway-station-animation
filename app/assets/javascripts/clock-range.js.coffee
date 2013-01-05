root = exports ? this

# requires jQuery to extend objects
root.ClockRange = class ClockRange
  @ANGLES =
    MIN: 0
    MAX: 2*Math.PI
    OFFSET: -Math.PI/2 # by default angle 0 is on the east. this moves it to the north

  @defaults =
    min: 0
    max: 60
    values: [15, 30]
    radius: 50 # radius of the clock face in pixels
    face: # options of the clock face
      margin: 14 # distance between the clock face and labels in pixels
      color: 'rgba(255, 255, 255, 1)' # color of the background
      border:
        color: '#FFECD1' # color of the border
        thickness: 1 # thickness of the border

    rangeColor: '#1FB8D0' # color of the range on the clock face
    label:
      color: 'rgb(141, 141, 141)' # color of the labels (0, 15', etc.)
      font: 'normal 12px Arial, sans-serif' # font of the labels (like in css)
      align: 'center' # text alignment within labels
      offset: # offset of all labels
        top: 6
        left: 0

  # @param canvas HTMLCanvasElement - canvas
  # @param values Array<Number> - 2-element array with values for range
  # @param options Hash - see ClockRange.defaults
  constructor: (@canvas, options) ->
    @ctx = @canvas.getContext('2d')

    @options = {}
    $.extend(true, @options, ClockRange.defaults, options || {})
    @values = @options.values

    @_init()

  setValues: (values) ->
    @values = values
    @_draw()

  _draw: ->
    @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
    @_drawClockFace()
    @_drawValues()
    @_updateTitle()

  _init: ->
    @center = @_center()
    @_draw()

  _drawClockFace: ->
    @_drawCircle(
      values: [@options.min, @options.max]
      radius: @options.radius
      fill: @options.face.color
    )

    if @options.face.border.thickness > 0
      @_drawCircle(
        values: [@options.min, @options.max]
        radius: @options.radius
        thickness: @options.face.border.thickness
        stroke: @options.face.border.color
      )

    labels = [
      { text: "0", position: "north" }
      { text: "15'", position: "east" }
      { text: "30'", position: "south" }
      { text: "45'", position: "west" }
    ]

    @_drawLabel($.extend(label, { offset: @options.label.offset })) for label in labels

  _drawValues: ->
    @_drawCircle(
      values: @values
      radius: @options.radius / 2
      thickness: @options.radius
      stroke: @options.rangeColor
    )

  _drawLabel: (options) ->
    @ctx.textAlign = @options.label.align
    @ctx.font = @options.label.font
    @ctx.fillStyle = @options.label.color
    position = @_positionByName(options.position)

    if options.offset?
      position.x += options.offset.left if options.offset.left?
      position.y += options.offset.top if options.offset.top?

    @ctx.fillText(options.text, position.x, position.y)

  _drawCircle: (options) ->
    angles =
      start: @_valueToAngle(options.values[0])
      end: @_valueToAngle(options.values[1])

    @ctx.beginPath()
    @ctx.arc(@center.x, @center.y, options.radius, angles.start, angles.end)
    @ctx.lineWidth = options.thickness || 0

    if options.stroke?
      @ctx.strokeStyle = options.stroke
      @ctx.stroke()
    if options.fill?
      @ctx.fillStyle = options.fill
      @ctx.fill()

  _updateTitle: ->
    @canvas.title = "#{@values[0]} - #{@values[1]} minutes"

  _positionByName: (name) ->
    position = { x: @center.x, y: @center.y }
    switch name
      when "north" then position.y -= (@options.radius + @options.face.margin)
      when "east" then position.x += (@options.radius + @options.face.margin)
      when "south" then position.y += (@options.radius + @options.face.margin)
      when "west" then position.x -= (@options.radius + @options.face.margin)
    position

  _valueToAngle: (value) ->
    ClockRange.ANGLES.MIN + (value - @options.min) / (@options.max - @options.min) * ClockRange.ANGLES.MAX + ClockRange.ANGLES.OFFSET

  _center: ->
    {
      x: @canvas.width/2
      y: @canvas.height/2
    }