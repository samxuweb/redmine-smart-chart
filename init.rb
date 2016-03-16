Redmine::Plugin.register :smart_chart do
  name 'Smart Chart plugin'
  author 'Sam Xu'
  description 'It can build a engineer loading chart and projects loading chart.'
  version '0.1.0'
  url 'https://github.com/samxuweb/smart_chart'
  author_url 'https://github.com/samxuweb'

  menu :top_menu, :smart_chart, { :controller => 'smart_charts', :action => 'show' }, :caption => 'Smart Chart', :if => Proc.new { User.current.admin? || Setting.plugin_smart_chart['user_ids'].split(",").include?(User.current.id.to_s) }, :caption => :label_smart_charts
  settings :default => {'empty' => true}, :partial => 'settings/smart_chart_settings'
end
