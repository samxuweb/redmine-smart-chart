# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'smart_charts',  :to => 'smart_charts#index'
get 'smart_charts/show',  :to => 'smart_charts#show'
get 'smart_charts/show-departments',  :to => 'smart_charts#showDepartments'
get 'smart_charts/show-details',  :to => 'smart_charts#showDetails'
get 'smart_charts/top10',  :to => 'smart_charts#top10'
get 'smart_charts/show-recent-month', :to => 'smart_charts#showRecentMonth'
