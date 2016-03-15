Redmine::Plugin.register :smart_chart do
  name 'Smart Chart plugin'
  author 'Sam Xu'
  description 'It can build a engineer loading chart and projects loading chart.'
  version '0.0.1'
  url 'https://github.com/samxuweb/smart_chart'
  author_url 'https://github.com/samxuweb'

  menu :top_menu, :smart_charts, { :controller => 'smart_charts', :action => 'show' }, :caption => 'Smart Chart', :if => Proc.new { User.current.admin? }
  settings :default => {'empty' => true}, :partial => 'settings/smart_chart_settings'
end
