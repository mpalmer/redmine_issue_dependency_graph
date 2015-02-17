# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
# resources :watchers do
#   member do
#     get 'preview_watchers'
#   end
# end
match 'issues/:id/issue_graph', :to => 'issue_dependency_graph#issue_graph', :as => 'issue_graph', :via => :get
match 'versions/:id/version_graph', :to => 'issue_dependency_graph#version_graph', :as => 'version_graph', :via => :get
