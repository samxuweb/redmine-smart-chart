class SmartChartsController < ApplicationController
  unloadable
  helper_method :depName

  def show
    if params[:dep]
      if params[:dep] == 'top10'
        datax, datay, title = topTenIssueOwner, topTenIssueNumber, l(:top_ten)
      else
        datax = depMember(params[:dep])
        datay = depMemberIssuesNumber(params[:dep])
        title = params[:dep]
      end
    else
      datax, datay, title = depName, depIssuesNumber, l(:department_chart)
    end

    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: title)
      f.xAxis(categories: datax)
      f.series(name: l(:issue_numbers), yAxis: 0, data: datay, dataLabels: {enabled: true})

      f.yAxis [
        {title: {text: l(:issue_numbers), margin: 70} },
      ]

      f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical')
      f.chart({defaultSeriesType: "column"})
    end

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
  end

  def showDep
    Group.find_by_lastname(params[:dep]).users.map
  end

  def depName
    Group.where(:id => Setting.plugin_smart_chart['department_ids'].split(",")).map(&:name)
  end

#  private

  def topTen
    Issue.visible.open.select("assigned_to_id, count(assigned_to_id) as assignee").group("assigned_to_id").order("assignee DESC").limit(10).map(&:assigned_to_id)
  end

  def topTenIssueNumber
    number = topTen.collect {|user| Issue.where(:assigned_to_id => user).count}
  end

  def topTenIssueOwner
    owner = topTen.collect { |user| %Q{<a href="http://192.168.110.22#{issues_path(:set_filter => 1, :assigned_to_id => user)}">"#{User.find(user).name}"</a>}}
  end

  def depIssuesNumber
    number = []
    for group_id in Setting.plugin_smart_chart['department_ids'].split(",")
      number << Issue.visible.open.where(:assigned_to_id => Group.find(group_id).users.map(&:id)).count
    end
    number
  end

  def depMember(dep)
    Group.find_by_lastname(dep).users.map(&:name)
  end

  def depMemberIssuesNumber(dep)
    number = []
    Group.find_by_lastname(dep).users.map(&:id).each do |id|
      number << Issue.open.where(:assigned_to_id => id).count
    end
    number
  end
end
