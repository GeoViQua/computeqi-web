var e_colour_scheme = ['#edc240', '#afd8f8', '#cb4b4b', '#4da74d', '#9440ed'];

$e.plot = function($container, type, data) {
  switch (type) {
    case 'vs_observed_mean_plot':
      data.title = 'Reference versus observed mean, with error bars ±1 standard deviation';
      $e.plotVsObserved($container, data, 'mean');
      break;
    case 'vs_observed_median_plot':
      data.title = 'Reference versus observed median, with 25-75% confidence intervals';
      $e.plotVsObserved($container, data, 'median');
      break;
    case 'standard_score_plot':
      data.title = 'Standard score plot, 95% should fall within the two blue lines';
      $e.plotStandardScore($container, data);
      break;
    case 'mean_residual_histogram':
      data.title = 'Histogram of residuals from the mean';
      $e.plotResidualHistogram($container, data, 'mean');
      break;
    case 'mean_residual_qq_plot':
      data.title = 'Mean residual QQ plot';
      $e.plotResidualQQ($container, data, 'mean');
      break;
    case 'median_residual_histogram':
      data.title = 'Histogram of residuals from the median';
      $e.plotResidualHistogram($container, data, 'median');
      break;
    case 'median_residual_qq_plot':
      data.title = 'Median residual QQ plot';
      $e.plotResidualQQ($container, data, 'median');
      break;
    case 'rank_histogram':
      data.title = 'Rank histogram plot, ideally should be flat, but sensitive to low numbers of observations';
      $e.plotHistogram($container, data, {
        xAxisLabel: 'Realisation number',
        yAxisLabel: 'Frequency of observation in that realisation'
      });
      break;
    case 'reliability_diagram':
      data.title = 'Reliability diagram, computed based on splitting the range of observations into 10 classes';
      $e.plotReliabilityDiagram($container, data);
      break;
    case 'coverage_plot':
      data.title = 'Coverage interval vs frequency that observation is in coverage interval, 20-98% coverage';
      $e.plotCoverage($container, data);
      break;
    default:
      $container.html('Unsupported plot type ' + type + '.');
  }
}

$e.baseParse = function(data) {
  // parse data
  var x = data.x;
  var y = data.y;
  var yError = data.yRange;
  var array = [];
  for (var i = 0; i < x.length; i++) {
    if (typeof(yError) === 'undefined') {
      array.push([x[i], y[i]]);
    } else {
      array.push([x[i], y[i], y[i] - yError[i][0], yError[i][1] - y[i]]);
    }
  }
  return array;
};

$e.calculateMinMax = function(data) {
  var minX;
  var maxX;
  var minY;
  var maxY;
  var minYwithError;
  var maxYwithError;
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
    if (typeof(data.yRange) !== 'undefined') {
      var tmpMin = (minY - (data.y[i] - data.yRange[i][0]));
      var tmpMax = ((data.yRange[i][1] - data.y[i]) + maxY);
      if (i == 0 || tmpMin < minYwithError) {
        minYwithError = tmpMin;
      }
      if (i == 0 || tmpMax > maxYwithError) {
        maxYwithError = tmpMax;
      }
    }
  }
  return {
    min: (minX < minY ? minX : minY),
    max: (maxX > maxY ? maxX : maxY),
    minX: minX,
    maxX: maxX,
    minY: minY,
    maxY: maxY,
    minYwithError: minYwithError,
    maxYwithError: maxYwithError };
};

$e.createLine = function(data) {
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
    points: { show: true, radius: 4 },
    color: e_colour_scheme[0] };
  return p;
};

$e.createPointsWithError = function(data) {
  var p = $e.createPoints(data);
  p.points = $.extend({}, p.points, {
    errorbars: 'y',
    yerr: { show: true, asymmetric: true, upperCap: '-', lowerCap: '-' }
  });
  return p;
}

$e.basePlot = function($container, data, options, title, formatter) {
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

  var $plotarea;
  if (typeof(title) !== 'undefined' && title != null) {
    var originalHeight = $container.height();
    $container.empty();
    $heading = $('<div>' + title + '</div>').addClass('plot-title').appendTo($container);
    var headingHeight = $heading.height() + parseInt($heading.css('margin-bottom'));
    $plotarea = $('<div></div>').css('height', originalHeight - headingHeight).appendTo($container);
  } else {
    $plotarea = $container;
  }
  var plot = $.plot($plotarea, data, merged);

  $plotarea.bind('plothover', function(event, position, item) {
    if (item) {
      if (plot.previousPoint != item.dataIndex) {
        plot.previousPoint = item.dataIndex;

        // remove old tooltip
        $('#plot-tooltip').remove();

        // default formatter if required
        var format = formatter;
        if (typeof(format) === 'undefined' || format == null) {
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
        var offset = 12;
        var left = item.pageX + offset;
        var top = item.pageY;
        if (left + $tooltip.width() > $(window).width()) {
          left = item.pageX - $tooltip.width() - (offset * 3);
        }

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

$e.plotHistogram = function($container, data, options) {
  var merged = $.extend({}, {
    xAxisLabel: 'X',
    yAxisLabel: 'Y'
  }, options);

  // create data
  var minMax = $e.calculateMinMax(data);
  var barWidth = ((minMax.maxX - minMax.minX) * 0.6) / data.x.length
  var pdata = [
    { label: 'k+',
      data: $e.baseParse(data),
      bars: { show: true, align: 'center', barWidth: barWidth } }
  ];

  // create options
  var options = {

    xaxes: [{
      axisLabel: merged.xAxisLabel
    }],
    yaxes: [{
      axisLabel: merged.yAxisLabel
    }]
  };

  $e.basePlot($container, pdata, options, data.title);
};

$e.plotVsObserved = function($container, data, source) {
  // create data
  var minMax = $e.calculateMinMax(data);
  var pdata = [
    $e.createLine([[minMax.min,minMax.min],[minMax.max,minMax.max]]),
    $e.createPointsWithError($e.baseParse(data))
  ];

  var minWithError = (minMax.minYwithError < minMax.min ? minMax.minYwithError : minMax.min);
  var maxWithError = (minMax.maxYwithError > minMax.max ? minMax.maxYwithError : minMax.max);

  // create options
  var options = {
    zoom: { interactive: true },
    pan: { interactive: true },
    xaxis: {
      min: minWithError,
      max: maxWithError,
      panRange: [minWithError, maxWithError]
    },
    yaxis: {
      min: minWithError,
      max: maxWithError,
      panRange: [minWithError, maxWithError]
    },
    xaxes: [{ axisLabel: 'Reference' }],
    yaxes: [{ axisLabel: 'Observed ' + source }]
  };

  // custom formatter
  // 'mean' is +/- 1 standard deviation
  // 'median' is 25% CI, 75% CI

  $e.basePlot($container, pdata, options, data.title);
};

$e.plotStandardScore = function($container, data) {
  // create data
  var pdata = [
    $e.createLine([[0,2],[data.x.length - 1,2]]),
    $e.createLine([[0,-2],[data.x.length - 1,-2]]),
    $e.createPoints($e.baseParse(data))
  ];

  // create options
  var options = {
    yaxis: { min: -4, max: 4 },
    xaxes: [{
      axisLabel: 'Index of observation in data set'
    }],
    yaxes: [{
      axisLabel: 'Standard score',
    }]
  };

  $e.basePlot($container, pdata, options, data.title);
};

$e.plotResidualHistogram = function($container, data, source) {
  $e.plotHistogram($container, data, {
    xAxisLabel: 'Residual from the ' + source,
    yAxisLabel: 'Frequency'
  });
};

$e.plotReliabilityDiagram = function($container, data) {
  // create data
  var pdata = [
    $e.createLine([[0,0],[1,1]]),
    $e.createPoints($e.baseParse(data))
  ];
      
  // create options
  var options = {
    yaxis: { min: 0, max: 1 },
    xaxes: [{
      axisLabel: 'Forecast probability'
    }],
    yaxes: [{
      axisLabel: 'Reference frequency',
    }]
  };

  var plot = $e.basePlot($container, pdata, options, data.title);

  // add data labels
  $.each(pdata[1].data, function(i, xy) {
    var offset = plot.pointOffset({ x: xy[0], y: xy[1] });
    var $label = $('<div class="plot-label"></div>');
    $label.html(data.n[i]); // lookup from original data
    $label.css({ left: offset.left + 8, top: offset.top });
    $label.appendTo(plot.getPlaceholder());
  });
};

$e.plotResidualQQ = function($container, data, source) {
  // create data
  var minMax = $e.calculateMinMax(data);
  var pdata = [
    $e.createLine([[minMax.min,minMax.min],[minMax.max,minMax.max]]),
    $e.createPoints($e.baseParse(data))
  ];

  // create options
  var options = {
    xaxis: { min: minMax.min, max: minMax.max },
    yaxis: { min: minMax.min, max: minMax.max },
    xaxes: [{
      axisLabel: 'Reference residual quantiles'
    }],
    yaxes: [{
      axisLabel: 'Observed ' + source + ' residual quantiles',
    }]
  };

  $e.basePlot($container, pdata, options, data.title);
};

$e.plotCoverage = function($container, data) {
  // create data
  var pdata = [
    $e.createLine([[20,20],[98,98]]),
    $e.createPoints($e.baseParse(data))
  ];

  // create options
  var options = {
    xaxis: { min: 20, max: 100 },
    yaxis: { min: 0, max: 100 },
    xaxes: [{ axisLabel: 'Theoretical coverage' }],
    yaxes: [{ axisLabel: 'Reference frequency in coverage interval' }]
  };

  $e.basePlot($container, pdata, options, data.title);
};
