class SmartChartsController < ApplicationController
  helper_method :depName

  before_action :checkPermission
  def index
    @date = Time.now
    @type = 'department'
    @datax, @datay, @title = depName, depIssuesNumber(issues), l(:department_chart)
    @datay[:rate] = []
    for i in 0...@datax.length do
      @datay[:rate][i] = (@datay[:closed][i] == 0) ? 0 : (@datay[:closed][i] * 100 / (@datay[:new][i] + @datay[:ongoing][i] + @datay[:closed][i]))
    end
  end

  def show
    @date = Time.now
    @title = params[:dep]
    @type = params[:dep]
    @datax = depMember(params[:dep])
    @datay = depMemberIssuesNumber(params[:dep], issues)
    @datay[:rate] = []
    for i in 0...@datax.length do
      @datay[:rate][i] = (@datay[:closed][i] == 0) ? 0 : (@datay[:closed][i] * 100 / (@datay[:new][i] + @datay[:ongoing][i] + @datay[:closed][i]))
    end
    render :action => 'index'
  end

  def top10
    @date = Time.now
    @title = l(:top_ten)
    @type = 'top10'
    @datax = topTenIssueOwner(issues)
    @datay = topTenIssueNumber(issues)
    @datay[:rate] = []
    for i in 0...@datax.length do
      @datay[:rate][i] = (@datay[:closed][i] == 0) ? 0 : (@datay[:closed][i] * 100 / (@datay[:new][i] + @datay[:ongoing][i] + @datay[:closed][i]))
    end
    render :action => 'index'
  end

  def showRecentMonth
    @date = Time.new(params[:year], params[:month]).end_of_month
    @type = params[:type]
    if params[:type] == 'department'
      @title = l(:department_chart) 
      @datax = depName
      @datay = depIssuesNumber(issues(@date))
    elsif params[:type] == 'top10'
      @title = l(:top_ten) 
      @datax = topTenIssueOwner(issues(@date))
      @datay = topTenIssueNumber(issues(@date))
    else
      @title = params[:type] 
      @datax = depMember(params[:type])
      @datay = depMemberIssuesNumber(params[:type], issues(@date))
    end
    @datay[:rate] = []
    for i in 0...@datax.length do
      @datay[:rate][i] = (@datay[:closed][i] == 0) ? 0 : (@datay[:closed][i] * 100 / (@datay[:new][i] + @datay[:ongoing][i] + @datay[:closed][i]))
    end
    respond_to do |format|
      format.js {}
    end
  end

  def showDep
    Group.find_by_lastname(params[:dep]).users.map
  end

  def depName
    Setting.plugin_smart_chart['department_ids'].split(",").collect {|id| Group.find(id).lastname}
  end

#  private

  def issues(date = Time.now.end_of_month)
    Issue.where(:tracker_id => 4).where("due_date < ? AND due_date > ?", date, date - 1.month)
  end

  def topTen(issues_from)
    issues_from.joins("LEFT JOIN #{User.table_name} on #{User.table_name}.id = #{Issue.table_name}.assigned_to_id").where("#{User.table_name}.status = 1").where(:tracker_id => 4).select("assigned_to_id, count(assigned_to_id) as assignee").group("assigned_to_id").order("assignee DESC").limit(10).map(&:assigned_to_id)
  end

  def topTenIssueNumber(issues_from)
    number = Hash.new
    number[:new] = topTen(issues_from).collect {|user| issues_from.where(:assigned_to_id => user, :status => 1).count}
    number[:ongoing] = topTen(issues_from).collect {|user| issues.where(:assigned_to_id => user, :status => [2,5]).count}
    number[:closed] = topTen(issues_from).collect {|user| issues.where(:assigned_to_id => user, :status => [3,4,6]).count}
    number
  end

  def topTenIssueOwner(issues_from)
    owner = topTen(issues_from).collect { |user| %Q{<a href="#{issues_url(:set_filter => 1, :assigned_to_id => user)}">"#{User.find(user).lastname}"</a>}}
  end

  def depIssuesNumber(issues_from)
    number = Hash.new
    number[:new], number[:ongoing], number[:closed] = [], [], [] 
    for group_id in Setting.plugin_smart_chart['department_ids'].split(",")
      issues_to = issues_from.where(:assigned_to_id => Group.find(group_id).users.where(:status => 1).map(&:id))
      number[:new] << issues_to.where(:status => 1).count
      number[:ongoing] << issues_to.where(:status => [2,5]).count
      number[:closed] << issues_to.where(:status => [3,4,6]).count
    end
    number
  end

  def depMember(dep)
    member = []
    Group.find_by_lastname(dep).users.each do |user|
      member << %Q{<a href="#{issues_url(:set_filter => 1, :assigned_to_id => user.id)}">"#{user.lastname}"</a>} if user.active?
    end
    member
  end

  def depMemberIssuesNumber(dep, issues_from)
    number = Hash.new
    number[:new], number[:ongoing], number[:closed] = [], [], []
    Group.find_by_lastname(dep).users.map(&:id).each do |id|
      if User.find(id).active?
        issues_to = issues_from.where(:assigned_to_id => id)
        number[:new] << issues_to.where(:status => 1).count
        number[:ongoing] << issues_to.where(:status => [2,5]).count
        number[:closed] << issues_to.where(:status => [3,4,6]).count
      end
    end
    number
  end

  def checkPermission
    redirect_to '/redmine' unless User.current.admin? || Setting.plugin_smart_chart['user_ids'].split(",").include?(User.current.id.to_s)
  end
end
