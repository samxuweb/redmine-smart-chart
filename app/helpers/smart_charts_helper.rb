module SmartChartsHelper

  def recentMonths
    thismonth = Time.now.end_of_month
    months = []
    for i in 0...12 do
      months << thismonth - i.month
    end
    months
  end

  def chart(title, datax, datay, date)
    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: title)
      f.subtitle(text: date.strftime('%Y-%m'))
      f.xAxis(categories: datax)
      f.series(name: l(:issue_numbers_new), yAxis: 0, data: datay[:new], dataLabels: {enabled: true})
      f.series(name: l(:issue_numbers_ongoing), yAxis: 0, data: datay[:ongoing], dataLabels: {enabled: true})
      f.series(name: l(:issue_numbers_closed), yAxis: 0, data: datay[:closed], dataLabels: {enabled: true})
      f.series(name: l(:rate), yAxis: 1, data: datay[:rate], dataLabels: {enabled: true})
      f.yAxis [
        {title: {text: l(:issue_numbers), margin: 70} },
        {title: {text: l(:rate)}, opposite: true },
      ]

      f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical')
      f.chart({defaultSeriesType: "column"})
    end
  end

  def chart_globals
    @chart_globals = LazyHighCharts::HighChartGlobals.new do |f|
      f.global(useUTC: false)
      f.chart(
        backgroundColor: {
          linearGradient: [0, 0, 500, 500],
          stops: [
            [0, "rgb(255, 255, 255)"],
            [1, "rgb(240, 240, 255)"]
          ]
        },
        borderWidth: 2,
        plotBackgroundColor: "rgba(255, 255, 255, .9)",
        plotShadow: true,
        plotBorderWidth: 1,
      )
      f.lang(thousandsSep: ",")
      f.colors(["#90ed7d", "#f7a35c", "#8085e9", "#f15c80", "#e4d354"])
    end
    @chart_globals
  end
end

