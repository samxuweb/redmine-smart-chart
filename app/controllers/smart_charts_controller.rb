class SmartChartsController < ApplicationController
  helper_method :depName

  before_action :checkPermission
  def index
    @date = Time.now
    @title = "All Issues"
    @data = allIssuesNumber('all', @date)
    @data[:rate] = []
    for i in 0...@data[:datax].length do
      @data[:rate][i] = (@data[:closed][i] == 0) ? 0 : (@data[:closed][i] * 100 / @data[:ongoing][i])
    end
  end

  def showDepartments
    @date = Time.now
    @datax, @datay = depName, depIssuesNumber(issues(@date))
    @datay[:rate] = []
    for i in 0...@datax.length do
      @datay[:rate][i] = (@datay[:closed][i] == 0) ? 0 : (@datay[:closed][i] * 100 / @datay[:ongoing][i])
    end
    @data = Hash.new
    @data[:datax] = @datax
    @data[:ongoing] = @datay[:ongoing]
    @data[:closed] = @datay[:closed]
    @data[:rate] = @datay[:rate]
  end

  def show
    @date = Time.now
    @title = params[:dep]
    @data = allIssuesNumber('group', @date, params[:dep])
    @members = depMember(params[:dep])
    @data[:rate] = []
    for i in 0...@data[:datax].length do
      @data[:rate][i] = (@data[:closed][i] == 0) ? 0 : (@data[:closed][i] * 100 / @data[:ongoing][i] )
    end
#    render :action => 'index'
  end

  def showRecentMonth
    month = params[:month]
    year = params[:year]
    if month == "0"
      month = 12
      year = year.to_i - 1
    elsif month == "13"
      month = 1
      year = year.to_i + 1
    end
    @date = Time.new(year, month).end_of_month
    @datax, @datay = depName, depIssuesNumber(issues(@date))
    @datay[:rate] = []
    for i in 0...@datax.length do
      @datay[:rate][i] = (@datay[:closed][i] == 0) ? 0 : (@datay[:closed][i] * 100 / @datay[:ongoing][i])
    end
    @data = Hash.new
    @data[:datax] = @datax
    @data[:ongoing] = @datay[:ongoing]
    @data[:closed] = @datay[:closed]
    @data[:rate] = @datay[:rate]
    respond_to do |format|
      format.js {}
    end
  end

  def showDetails
    @date = Time.now
    member = User.find(params[:member])
    @title = member.lastname
    @data = allIssuesNumber('user', @date, member.id)
    @data[:rate] = []
    for i in 0...@data[:datax].length do
      @data[:rate][i] = (@data[:closed][i] == 0) ? 0 : (@data[:closed][i] * 100 / @data[:ongoing][i] )
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

  def allIssuesNumber(type, date, d = '')
    number = Hash.new
    number[:datax], number[:new], number[:ongoing], number[:closed] =  [], [], [], []
    9.downto 0 do |i| 
      date_new = date - i.month
      if type == "all"
        issues_from = issues(date_new)
      elsif type == "group"
        issues_from = issues(date_new).where(:assigned_to_id => Group.find_by_lastname(d).users.where(:status => 1).map(&:id))
      elsif type == "user"
        issues_from = issues(date_new).where(:assigned_to_id => d)
      end
#      number[:new] << issues_from.where(:status => 1).count
      number[:ongoing] << issues_from.count
      number[:closed] << issues_from.where(:status => [3,4,6]).count
      number[:datax] << date_new.strftime('%Y-%m')
    end
      number
  end

  def depIssuesNumber(issues_from)
    number = Hash.new
    number[:new], number[:ongoing], number[:closed] = [], [], [] 
    for group_id in Setting.plugin_smart_chart['department_ids'].split(",")
      issues_to = issues_from.where(:assigned_to_id => Group.find(group_id).users.where(:status => 1).map(&:id))
#      number[:new] << issues_to.where(:status => 1).count
      number[:ongoing] << issues_to.count
      number[:closed] << issues_to.where(:status => [3,4,6]).count
    end
    number
  end

  def depMember(dep)
    member = []
    Group.find_by_lastname(dep).users.each do |user|
      member << user if user.active?
    end
    member
  end

  def checkPermission
    redirect_to '/redmine' unless User.current.admin? || Setting.plugin_smart_chart['user_ids'].split(",").include?(User.current.id.to_s)
  end
end
