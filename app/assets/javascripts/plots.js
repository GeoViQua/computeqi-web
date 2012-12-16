var e_colour_scheme = ['#edc240', '#afd8f8', '#cb4b4b', '#4da74d', '#9440ed'];

$e.plot = function($container, type, data) {
  switch (type) {
    case 'standard_score_plot':
      $e.plotStandardScore($container, data);
      break;
    case 'mean_residual_histogram':
      $e.plotResidualHistogram($container, data, 'mean');
      break;
    case 'mean_residual_qq_plot':
      $e.plotResidualQQ($container, data, 'mean');
      break;
    case 'median_residual_histogram':
      $e.plotResidualHistogram($container, data, 'median');
      break;
    case 'median_residual_qq_plot':
      $e.plotResidualQQ($container, data, 'median');
      break;
    case 'reliability_diagram':
      $e.plotReliabilityDiagram($container, data);
      break;
    default:
      $container.html('Unsupported plot type ' + type + '.');
  }
}

$e.baseParse = function(data) {
  // parse data
  var x = data.x;
  var y = data.y;
  var array = [];
  for (var i = 0; i < x.length; i++) {
    array.push([x[i], y[i]]);
  }
  return array;
};

$e.calculateMinMax = function(data) {
  var minX;
  var maxX;
  var minY;
  var maxX;
  for (var i = 0; i < data.x.length; i++) {
    if (i == 0 || data.x[i] < minX) {
      minX = data.x[i];
    }
    if (i == 0 || data.x[i] > maxX) {
      maxX = data.x[i];
    }
    if (i == 0 || data.y[i] < minY) {
      minY = data.y[i];
    }
    if (i == 0 || data.y[i] > maxY) {
      maxY = data.y[i];
    }
  }
  return { minX: minX, maxX: maxX, minY: minY, maxY: maxY };
};

$e.createBackgroundLine = function(data) {
  var l = {
    label: 'r',
    data: data,
    lines: { show: true },
    color: e_colour_scheme[1],
    hoverable: false };
  return l;
};

$e.createPoints = function(data) {
  var p = {
    label: 'k+',
    data: data,
    points: { show: true, radius: 5 },
    color: e_colour_scheme[0] };
  return p;
}

$e.basePlot = function($container, data, options, formatter) {
  var merged = $.extend({}, {
    colors: e_colour_scheme,
    grid: {
      borderWidth: 0,
      hoverable: true
    },
    legend: {
      show: false
    }
  }, options);

  var plot = $.plot($container, data, merged);

  $container.bind('plothover', function(event, position, item) {
    if (item) {
      if (plot.previousPoint != item.dataIndex) {
        plot.previousPoint = item.dataIndex;

        // remove old tooltip
        $('#plot-tooltip').remove();

        // default formatter if required
        var format = formatter;
        if (typeof(format) === 'undefined') {
          format = function($div, item) {
            var datapoint = item.datapoint;
            $div.html('x: ' + datapoint[0].toFixed(2) + ', ' + 'y: ' + datapoint[1].toFixed(2));
          }
        }

        // create new tooltip
        $tooltip = $('<div id="plot-tooltip" class="plot-tooltip"></div>').appendTo('body');

        // format it
        format($tooltip, item);

        // calculate position
        var left = item.pageX + 12;
        var top = item.pageY;
        // if (left + $tooltip.width() > $(window).width()) {
        //   left = position.pageX - offset - $tooltip.width();
        // } else {
        //   left = left + offset;
        // }

        // set position
        $tooltip.css({ left: left, top: top });
        $tooltip.css('border-color', item.series.color);

        // and show it
        $tooltip.fadeIn();
      }
    } else {
      plot.previousPoint = null;
      $('#plot-tooltip').fadeOut('fast', function() {
        $(this).remove();
      });
    }
  });

  return plot;
};

$e.plotStandardScore = function($container, data) {
  // create data
  var pdata = [
    $e.createBackgroundLine([[0,0],[data.x.length - 1,0]]),
    $e.createPoints($e.baseParse(data))
  ];

  // create options
  var options = {
    yaxis: { min: -2, max: 2 },
    xaxes: [{
      axisLabel: 'Index'
    }],
    yaxes: [{
      axisLabel: 'Standard score',
    }]
  };

  var formatter = function($div, item) {
    $div.html(item.datapoint[1].toFixed(2));
  };

  $e.basePlot($container, pdata, options, formatter);
};

$e.plotResidualHistogram = function($container, data, source) {
  // create data
  var minMax = $e.calculateMinMax(data);
  var barWidth = ((minMax.maxX - minMax.minX) * 0.6) / data.x.length
  var pdata = [
    { label: 'k+',
      data: $e.baseParse(data),
      bars: { show: true, align: 'center', barWidth: barWidth } }
  ];

  // x = 70 / 30

  // create options
  var options = {
    xaxes: [{
      axisLabel: 'Residual from the ' + source
    }],
    yaxes: [{
      axisLabel: 'Frequency',
    }]
  };

  $e.basePlot($container, pdata, options);
};

$e.plotReliabilityDiagram = function($container, data) {
  // create data
  var pdata = [
    $e.createBackgroundLine([[0,0],[1,1]]),
    $e.createPoints($e.baseParse(data))
  ];
      
  // create options
  var options = {
    yaxis: { min: 0, max: 1 },
    xaxes: [{
      axisLabel: 'Forecast probability'
    }],
    yaxes: [{
      axisLabel: 'Observed frequency',
    }]
  };

  var plot = $e.basePlot($container, pdata, options);

  // add data labels
  $.each(pdata[1].data, function(i, xy) {
    var offset = plot.pointOffset({ x: xy[0], y: xy[1] });
    var $label = $('<div class="plot-label"></div>');
    $label.html(data.n[i]); // lookup from original data
    $label.css({ left: offset.left + 10, top: offset.top });
    $label.appendTo(plot.getPlaceholder());
  });
};

$e.plotResidualQQ = function($container, data, source) {
  // create data
  var minMax = $e.calculateMinMax(data);
  var pdata = [
    $e.createBackgroundLine([[minMax.minX,minMax.minY],[minMax.maxX,minMax.maxY]]),
    $e.createPoints($e.baseParse(data))
  ];

  // create options
  var options = {
    xaxis: { min: minMax.xMin, max: minMax.xMax },
    yaxis: { min: minMax.yMin, max: minMax.yMax },
    xaxes: [{
      axisLabel: 'Observed residual quantiles'
    }],
    yaxes: [{
      axisLabel: 'Predicted ' + source + ' residual quantiles',
    }]
  };

  $e.basePlot($container, pdata, options);
};