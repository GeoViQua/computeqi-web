$e.plot = function($container, data, options, formatter) {
  var merged = $.extend({}, {
    grid: {
      borderWidth: 0,
      hoverable: true
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
        var graphic = { height: 2 };
        // not a fan of the arbitrary numbers
        var offset = 5;
        var top = position.pageY + offset;
        var left = position.pageX;
        if (left + $tooltip.width() > $(window).width()) {
          left = position.pageX - offset - $tooltip.width();
        } else {
          left = left + offset;
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
};

$e.plotStandardScore = function($container, data) {
  // parse data
  var x = data.x;
  var y = data.y;
  var array = [];
  for (var i = 0; i < x.length; i++) {
    array.push([x[i], y[i]]);
  }
  var pdata = [
    { label: 'Standard score', data: array }
  ];

  // options
  var options = {
    legend: {
      show: false
    },
    series: {
      points: {
        show: true,
        radius: 5
      }
    },
    yaxis: {
      min: -2,
      max: 2
    },
    xaxes: [{
      axisLabel: 'Index'
    }],
    yaxes: [{
      position: 'left',
      axisLabel: 'Standard score',
    }]
  };

  var formatter = function($div, datapoint) {
    $div.html('hah hah ah ah aha' + datapoint[1].toFixed(2));
  };

  $e.plot($container, pdata, options, formatter);
};