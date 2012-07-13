var DECIMAL_PLACES = 2;

function showTooltip(x, y, contents, colour) {
  $tooltip = $('<div id="flot-tooltip">' + contents + '</div>').css({top: y + 5, left: x + 5});
  if (colour) {
    $tooltip.css('background-color', colour);
  }
  $tooltip.appendTo('body').fadeIn();
}

function remoteUpdateFastPlot(plot, url, params) {
  $.get(url, params, function(data) {
    plot.setData(parseFastData(data).data);
    plot.setupGrid();
    plot.draw();
  });
}

function parseFastData(json) {
  // for ticks
  var ticks = [];

  // data
  var main = [];
  var interactions = [];
  for (var x = 1; x <= json.inputResults.length; x++) {
    var result = json.inputResults[x - 1];

    // ticks
    ticks.push([x, result.inputIdentifier]);

    // values
    main.push([x, result.mainEffect / result.variance]);
    interactions.push([x, 1 - result.interactions / result.variance - result.mainEffect / result.variance]);
  }

  return { ticks: ticks, data: [
    { label: 'Main', data: main },
    { label: 'Interactions', data: interactions }
  ] };
}

function createFastPlot(container, json) {
  // get data
  var parsed = parseFastData(json);

  // plot
  var options = {
    grid: {
      borderWidth: 0,
      hoverable: true
    },
    series: {
      stack: 0,
      lines: { show: false, steps: false },
      bars: { show: true, align: 'center' }
    },
    xaxis: {
      ticks: parsed.ticks,
      rotateTicks: 45
    }
  };

  // create
  var element = $('#' + container);
  var plot = $.plot(element, parsed.data, options);

  // add hover listener
  element.bind('plothover', function(e, pos, item) {
    if (item) {
      if (plot.previousPoint != item.dataIndex) {
        plot.previousPoint = item.dataIndex;
        $('#flot-tooltip').remove();
        var x = item.datapoint[0].toFixed(DECIMAL_PLACES);
        var y = item.datapoint[1].toFixed(DECIMAL_PLACES);
        var longest = 'Original';
        showTooltip(item.pageX, item.pageY, '<pre>' + parsed.ticks[item.dataIndex][1] + '<br/><br/>' + item.series.label + ' = ' + item.series.data[item.datapoint[0] - 1][1].toFixed(DECIMAL_PLACES), item.series.color);
      }
    } else {
      plot.previousPoint = null;
      $('#flot-tooltip').fadeOut(function() {
        $(this).remove();
      });
    }
  });

  return plot;
}

function remoteUpdateSensitivityPlots(plot, mainPlot, totalPlot, url, params) {
  $.get(url, params, function(data) {
    plot.setData(parseCombinedSensitivityData(data).data);
    plot.setupGrid();
    plot.draw();

    mainPlot.setData(parseSensitivityData(data, 'main').data);
    mainPlot.setupGrid();
    mainPlot.draw();

    totalPlot.setData(parseSensitivityData(data, 'total').data);
    totalPlot.setupGrid();
    totalPlot.draw();
  });
}

function parseSensitivityData(json, type) {
  // for ticks
  var ticks = [];

  // data
  var data = [];
  for (var x = 1; x <= json.inputResults.length; x++) {
    var result = json.inputResults[x - 1];

    // ticks
    ticks.push([x, result.inputIdentifier]);

    // values
    var y, ymin, ymax;
    if (type === 'main') {
      y = result.firstOriginal;
      ymin = result.firstMinCI;
      ymax = result.firstMaxCI; 
    } else {
      y = result.totalOriginal;
      ymin = result.totalMinCI;
      ymax = result.totalMaxCI; 
    }
    data.push([x, y, y - ymin, ymax - y]);
  }

  // setup points
  var points = {
    radius: 4,
    errorbars: 'y',
    yerr: { show: true, asymmetric: true, upperCap: '-', lowerCap: '-' }, 
  }

  var colour;
  if (type == 'main') {
    colour = '#edc240';
  } else {
    colour = '#afd8f8';
    points.symbol = 'triangle';
  }

  return { ticks: ticks, data: [{ points: points, data: data, label: type.charAt(0).toUpperCase() + type.slice(1) + ' effect', color: colour }] };
}

function parseCombinedSensitivityData(json) {
    // for adding ticks
  var ticks = [];

  // get effect
  var main = [];
  var total = [];
  var x = 1;
  for (var i in json.inputResults) {
    var result = json.inputResults[i];

    // ticks
    ticks.push([x, result.inputIdentifier]);

    // main
    var fo = result.firstOriginal;
    main.push([x, fo, fo - result.firstMinCI, result.firstMaxCI - fo]);
    x++;

    // total
    var to = result.totalOriginal;
    total.push([x, to, to - result.totalMinCI, result.totalMaxCI - to]);
    x++;
  }

  // setup points
  var mainPoints = {
    radius: 4,
    errorbars: 'y',
    yerr: { show: true, asymmetric: true, upperCap: '-', lowerCap: '-' }, 
  }

  var totalPoints = {
    radius: 4,
    symbol: 'triangle',
    errorbars: 'y',
    yerr: { show: true, asymmetric: true, upperCap: '-', lowerCap: '-' }, 
  }

  // data
  var data = [
    { points: mainPoints, data: main, label: 'Main effect', color: '#edc240' },
    { points: totalPoints, data: total, label: 'Total effect', color: '#afd8f8' }
  ];

  return { ticks: ticks, data: data };
}

function createSensitivityPlot(container, json, type) {
  // get data
  var parsed = parseSensitivityData(json, type);

  // plot
  var options = {
    grid: {
      borderWidth: 0,
      hoverable: true
    },
    xaxis: {
      ticks: parsed.ticks,
      rotateTicks: 45
    },
    yaxis: {
      min: -2,
      max: 2
    },
    series: { points: { show: true }}
  };

  // create
  var element = $('#' + container);
  var plot = $.plot(element, parsed.data, options);

  // add hover listener
  element.bind('plothover', function(e, pos, item) {
    if (item) {
      if (plot.previousPoint != item.dataIndex) {
        plot.previousPoint = item.dataIndex;
        $('#flot-tooltip').remove();
        var x = item.datapoint[0].toFixed(DECIMAL_PLACES);
        var y = item.datapoint[1].toFixed(DECIMAL_PLACES);
        var longest = 'Original';
        showTooltip(item.pageX, item.pageY, '<pre>' + parsed.ticks[item.dataIndex][1] + '<br/>' + item.series.label + '<br/><br/>Original = ' + y + '<br/>' + pad('Min CI', longest.length) + ' = ' + (parseFloat(y) - item.datapoint[2]).toFixed(DECIMAL_PLACES) + '<br/>' + pad('Max CI', longest.length) + ' = ' + (parseFloat(y) + item.datapoint[3]).toFixed(DECIMAL_PLACES) + '</pre>');
      }
    } else {
      plot.previousPoint = null;
      $('#flot-tooltip').fadeOut(function() {
        $(this).remove();
      });
    }
  });

  return plot;
}

function createCombinedSensitivityPlot(container, json) {
  var parsed = parseCombinedSensitivityData(json);

  // options
  var options = {
    grid: {
      borderWidth: 0,
      hoverable: true
    },
    xaxis: {
      ticks: parsed.ticks,
      rotateTicks: 45
    },
    yaxis: {
      min: -2,
      max: 2
    },
    series: { points: { show: true }}
  };
  
  // create plot
  var element = $('#' + container);
  var plot = $.plot(element, parsed.data, options);

  // add hover listener
  element.bind('plothover', function(e, pos, item) {
    if (item) {
      if (plot.previousPoint != item.dataIndex) {
        plot.previousPoint = item.dataIndex;
        $('#flot-tooltip').remove();
        var x = item.datapoint[0].toFixed(DECIMAL_PLACES);
        var y = item.datapoint[1].toFixed(DECIMAL_PLACES);
        var longest = 'Original';
        showTooltip(item.pageX, item.pageY, '<pre>' + parsed.ticks[item.dataIndex][1] + '<br/>' + item.series.label + '<br/><br/>Original = ' + y + '<br/>' + pad('Min CI', longest.length) + ' = ' + (parseFloat(y) - item.datapoint[2]).toFixed(DECIMAL_PLACES) + '<br/>' + pad('Max CI', longest.length) + ' = ' + (parseFloat(y) + item.datapoint[3]).toFixed(DECIMAL_PLACES) + '</pre>');
      }
    } else {
      plot.previousPoint = null;
      $('#flot-tooltip').fadeOut(function() {
        $(this).remove();
      });
    }
  });

  return plot;
}

function createValidationOutputPlot(container, json) {
  // get data
  var xmin;
  var xmax;
  var ymin;
  var ymax;
  var data = [];
  for (var i in json.emulatorMean) {
    var mean = json.emulatorMean[i];
    var variance = json.emulatorVariance[i];
    var sim = json.simulator[i];
    var tsds = 2 * Math.sqrt(variance);
    data.push([sim,mean,tsds]);
    if (!xmin || sim < xmin) {
      xmin = sim;
    }
    if (!xmax || sim > xmax) {
      xmax = sim;
    }
    if (!ymin || mean < ymin) {
      ymin = mean;
    }
    if (!ymax || mean > ymax) {
      ymax = mean;
    }
  }

  // get min, max
  var min = (xmin < ymin ? xmin : ymin);
  var max = (xmax > ymax ? xmax : ymax);

  // setup points
  var points = {
    errorbars: 'y',
    yerr: { show: true, asymmetric: false, upperCap: '-', lowerCap: '-' }, 
  }

  // options
  var options = {
    series: {
      points: {
        radius: 4,
        show: true
      }
    },
    grid: {
      borderWidth: 0,
      hoverable: true
    },
    xaxis: {
      min: min,
      max: max
    },
    yaxis: {
      min: min,
      max: max
    },
    xaxes: [{
      axisLabel: 'Simulator output',
    }],
    yaxes: [{
      position: 'left',
      axisLabel: 'Emulator output',
    }]
  };
  
  // create plot
  var element = $('#' + container);
  var plot = $.plot(element, [{ points: points, data: data }], options);

  // add hover listener
  element.bind('plothover', function(e, pos, item) {
    if (item) {
      if (plot.previousPoint != item.dataIndex) {
        plot.previousPoint = item.dataIndex;
        $('#flot-tooltip').remove();
        var x = item.datapoint[0].toFixed(DECIMAL_PLACES);
        var y = item.datapoint[1].toFixed(DECIMAL_PLACES);
        showTooltip(item.pageX, item.pageY, '<pre>Simulator output = ' + x + '<br/> Emulator output = ' + y + '<br/>            2*SD = ' + item.datapoint[2].toFixed(DECIMAL_PLACES) + '</pre>');
      }
    } else {
      plot.previousPoint = null;
      $('#flot-tooltip').fadeOut(function() {
        $(this).remove();
      });
    }
  });

  // return it
  return plot;
}

function createValidationPlot(container, json) {
  // get data
  var scoreData = [];
  for (var i in json.zScores) {
    var score = json.zScores[i];
    scoreData.push([i,score]);
  }
  data = [ { name: 'Standard score', data: scoreData } ];
  
  return new Highcharts.Chart({
    chart: {
      renderTo: container,
      type: 'scatter'
    },
    title: { text: null },
    credits: { enabled: false },
    xAxis: { title: { text: 'Index' } },
    yAxis: { title: { text: 'Standard score' } },
    legend: { enabled: false },
    plotOptions: {
      scatter: {
        marker: { radius: 5 },
      }
    },
    tooltip: {
      formatter: function() {
        return 'Standard score = ' + Highcharts.numberFormat(this.y, DECIMAL_PLACES);
      }
    },
    series: data
  });
}

function createScreeningPlot(container, json) {
  // get data
  var data = parseScreeningPlotData(json);

  return new Highcharts.Chart({
    chart: {
      renderTo: container,
      zoomType: 'x',
      type: 'scatter',
      events: {
        selection: function() {
          $('#popup').hide();
        }
      }
    },
    title: { text: null },
    credits: { enabled: false },
    xAxis: { title: { text: 'meanStarEE' } },
    yAxis: { title: { text: 'stdEE' } },
    plotOptions: {
      series: {
        events: {
          legendItemClick: function(event) {
            $popup = $('#popup');
            if ($popup.is(':visible') && $popup.find('h3').text() === event.target.name) {
              $popup.hide();
            }
          }
        }
      },
      scatter: {
        marker: { radius: 5 },
        cursor: 'pointer',
        events: {
          click: function(event) {
            var point = event.point;
            var series = point.series;
            var graphic = point.graphic;
            $popup = $('#popup');

            // get content
            var data = {
              url: $('.template').data('simulatorSpecificationUrl') + '/inputs/' + series.name,
              name: series.name,
              meanStarEE: Highcharts.numberFormat(point.x, DECIMAL_PLACES, '.'),
              stdEE: Highcharts.numberFormat(point.y, DECIMAL_PLACES, '.')
            };
            $.get(data.url, function(res) {
              // set min/max
              data.minimumValue = res.minimum_value;
              data.maximumValue = res.maximum_value;

              // suggested value average of min/max
              data.fixedValue = data.minimumValue + ((data.maximumValue - data.minimumValue) / 2);

              // apply template
              html = Mustache.to_html($('.template').val(), data);
              $('#popup').html(html);
              $('#popup .close').on('click', function() {
                $('#popup').hide();
              });

              // calculate position
              // not a fan of the arbitrary numbers
              var top = event.point.pageY - Math.floor($('#popup').height() / 2) - (graphic.height / 2);
              var left = event.point.pageX + 25;
              if (left + $popup.width() > $(window).width()) {
                left = event.point.pageX - 50 - $popup.width();
                $popup.removeClass('right').addClass('left');
              } else {
                $popup.removeClass('left').addClass('right');
              }

              // set css
              $('#popup').css({ left: left, top: top, 'border-color': series.color }).show();
            });
          }
        }
      }
    },
    tooltip: false,
    series: data
  });
}

function remoteUpdateScreeningPlot(plot, url, params) {
  // display loading overlay
  plot.showLoading();
  
  // load data
  $.get(url, params, function(response) {
    var data = parseScreeningPlotData(response);
    
    // update chart
    for (var i in plot.series) {
      plot.series[i].setData(data[i].data);
    }
    plot.redraw();
    
    // all done
    plot.hideLoading();
  }, 'json');
}

function createHistogram(container, json, name, bins) {
  // get data
  var data = parseHistogramData(json, name, bins);
  
  return new Highcharts.Chart({
    chart: {
      renderTo: container,
      type: 'column'
    },
    title: { text: null },
    credits: { enabled: false },
    yAxis: {
      min: 0,
      title: { text: null }
    },
    legend: { enabled: false },
    tooltip: {
      formatter: function() {
        // no need for Highcharts.numberFormat as y is always an integer, x rounded in parse
        return this.x + ': ' + this.y;
      }
    },
    xAxis: {
      categories: data.categories
    },
    series: data.series
  });
}

function remoteUpdateHistogram(histogram, url, params, name, bins) {
  // display loading overlay
  histogram.showLoading();
  
  // load data
  $.get(url, params, function(response) {
    var data = parseHistogramData(response, name, bins);
    
    // update chart
    histogram.xAxis[0].setCategories(data.categories);
    histogram.series[0].setData(data.series[0].data);
    histogram.redraw();
    
    // all done
    histogram.hideLoading();
  }, 'json');
}

function parseScreeningPlotData(data) {
  var results = data.inputResults;
  var data = [];
  for (var i in results) {
    var result = results[i];
    data.push({ name: result.inputIdentifier, data: [[result.meanStarEE,result.stdEE]] })
  }
  return data;
}

function parseHistogramData(data, name, bins) {
  // extract points
  var points = data[name];
  
  // find min/max
	var min;
	var max;
	for (var i in points) {
		var point = points[i];
		if (i == 0) {
			min = point;
			max = point;
		}
		if (point > max) {
			max = point;
		}
		if (point < min) {
			min = point;
		}
	}								

	// calculate bin width
	var binWidth = (max - min) / bins;
	
	// create data
	var data = [];
	var categories = [];
	if (binWidth == 0) {
		// special case for no range in data
		data.push(points.length);
	} else {		
		for (var i = 0; i < bins; i++) {
			var d = min + (i * binWidth);
			categories.push(d.toFixed(DECIMAL_PLACES));
			data.push(0);
		}								
		
		for (var i in points) {
			var point = points[i];
			var bin = Math.ceil(Math.abs(min - point) / binWidth);
			if (bin > bins) {
				// this is a javascript rounding error only in the case of the max value
				bin = bins;
			}
			var pos = (bin == 0 ? 1 : bin) - 1;
			var current = data[pos];
			data[pos] = current + 1;
		}
	}
  return { categories: categories,
    series: [
      { data: data }
    ] };
}

function pad(string, length) {
  var padded = string;
  while (padded.length < length) {
    padded = ' ' + padded;
  }
  return padded;
}