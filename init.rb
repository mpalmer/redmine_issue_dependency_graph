require 'redmine'

require_dependency 'issue_dependency_graph/hooks'

Redmine::Plugin.register :redmine_issue_dependency_graph do
	name 'Redmine Issue Dependency Graph Plugin'
	author "Matt Palmer, based on work by Jean-Phillippe Lang (redmine issue #2448)"
	version "0.0.1"
end

