$e.plot = function($container, type, data) {
  switch (type) {
    case 'standard_score':
      $e.plotStandardScore($container, data);
      break;
    case 'mean_residual':
      $e.plotResidual($container, data, 'mean');
      break;
    case 'median_residual':
      $e.plotResidual($container, data, 'median');
      break;
    case 'reliability':
      $e.plotReliability($container, data);
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
}

$e.basePlot = function($container, data, options, formatter) {
  var merged = $.extend({}, {
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
          format = function($div, datapoint) {
            $div.html('x: ' + datapoint[0].toFixed(2) + ', ' + 'y: ' + datapoint[1].toFixed(2));
          }
        }

        // create new tooltip
        $tooltip = $('<div id="plot-tooltip" class="plot-tooltip"></div>').appendTo('body');

        // format it
        format($tooltip, item.datapoint);

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
    { label: 'Standard score',
      data: $e.baseParse(data),
      points: {
        show: true,
        radius: 5
      } }
  ];

  // create options
  var options = {
    yaxis: {
      min: -2,
      max: 2
    },
    xaxes: [{
      axisLabel: 'Index'
    }],
    yaxes: [{
      axisLabel: 'Standard score',
    }]
  };

  var formatter = function($div, datapoint) {
    $div.html(datapoint[1].toFixed(2));
  };

  $e.basePlot($container, pdata, options, formatter);
};

$e.plotResidual = function($container, data, source) {
  // create data
  var pdata = [
    { label: 'Frequency',
      data: $e.baseParse(data),
      bars: { show: true, align: 'center' } }
  ];

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

$e.plotReliability = function($container, data) {
  // create data
  var pdata = [
    { label: 'Observed frequency',
      data: $e.baseParse(data),
      points: { show: true, radius: 5 } },
    { label: 'Identity',
      data: [[0,0],[1,1]],
      lines: { show: true },
      hoverable: false }
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
  $.each(pdata[0].data, function(i, xy) {
    var offset = plot.pointOffset({ x: xy[0], y: xy[1] });
    var $label = $('<div class="plot-label"></div>');
    $label.html(data.n[i]); // lookup from original data
    $label.css({ left: offset.left + 10, top: offset.top });
    $label.appendTo(plot.getPlaceholder());
  });
};