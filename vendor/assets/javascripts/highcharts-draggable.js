/** 
 * http://jsfiddle.net/highcharts/AyUbx/
 * Experimental Draggable points plugin
 * Revised 2012-11-22
 */
(function(Highcharts) {
  var addEvent = Highcharts.addEvent,
      each = Highcharts.each;

  function filterRange(newY, series) {
    var options = series.options,
        dragMin = options.dragMinY,
        dragMax = options.dragMaxY;
    
    if (newY < dragMin) {
      newY = dragMin;
    } else if (newY > dragMax) {
      newY = dragMax;
    }
    return newY;
  }

  Highcharts.Chart.prototype.callbacks.push(function(chart) {        
    var container = chart.container,
        dragPoint,
        dragX,
        dragY,
        dragPlotX,
        dragPlotY;
    
    chart.redraw(); // kill animation (why was this again?)
    
    addEvent(container, 'mousedown', function(e) {
      var hoverPoint = chart.hoverPoint,
          options;
      
      if (hoverPoint) {
        options = hoverPoint.series.options;
        if (options.draggableX) {
          dragPoint = hoverPoint;
          
          dragX = e.pageX;
          dragPlotX = dragPoint.plotX;
        }
        
        if (options.draggableY) {
          dragPoint = hoverPoint;
          
          dragY = e.pageY;
          dragPlotY = dragPoint.plotY + (chart.plotHeight - (dragPoint.yBottom || chart.plotHeight));
        }
        
        // Disable zooming when dragging
        if (dragPoint) {
          chart.mouseIsDown = false;
        }
      }
    });
    
    addEvent(container, 'mousemove', function(e) {
      if (dragPoint) {
        var deltaY = dragY - e.pageY,
            deltaX = dragX - e.pageX,
            newPlotX = dragPlotX - deltaX - dragPoint.series.xAxis.minPixelPadding,
            newPlotY = chart.plotHeight - dragPlotY + deltaY,
            newX = dragX === undefined ? 
                dragPoint.x :                        
                dragPoint.series.xAxis.translate(newPlotX, true),
            newY = dragY === undefined ?
                dragPoint.y :                        
                dragPoint.series.yAxis.translate(newPlotY, true),
            series = dragPoint.series;
        
        newY = filterRange(newY, series);

        dragPoint.update([newX, newY], false);
        chart.tooltip.refresh(dragPoint);
        if (series.stackKey) {
          chart.redraw();
        } else {
          series.redraw();
        }
      }
    });
    
    function drop(e) {
      if (dragPoint) {
        var deltaX = dragX - e.pageX,
            deltaY = dragY - e.pageY,
            newPlotX = dragPlotX - deltaX - dragPoint.series.xAxis.minPixelPadding,
            newPlotY = chart.plotHeight - dragPlotY + deltaY,
            series = dragPoint.series,
            newX = dragX === undefined ? 
                dragPoint.x :                        
                dragPoint.series.xAxis.translate(newPlotX, true),
            newY = dragY === undefined ?
                dragPoint.y :                        
                dragPoint.series.yAxis.translate(newPlotY, true);           
        
        newY = filterRange(newY, series);
        dragPoint.firePointEvent('drop');
        dragPoint.update([newX, newY]);
            
        dragPoint = dragX = dragY = undefined;
      }
    }
    addEvent(document, 'mouseup', drop);
    addEvent(container, 'mouseleave', drop);
  });
  
  /**
   * Extend the column chart tracker by visualizing the tracker object for small points
   */
  var colProto = Highcharts.seriesTypes.column.prototype,
      baseDrawTracker = colProto.drawTracker;
  
  colProto.drawTracker = function() {
    var series = this;
    baseDrawTracker.apply(series);
    
    each(series.points, function(point) {
      point.tracker.attr(point.shapeArgs.height < 3 ? {
        'stroke': 'black',
        'stroke-width': 2,
        'dashstyle': 'shortdot'
      } : {
        'stroke-width': 0
      });
    });
  };
  
})(Highcharts);