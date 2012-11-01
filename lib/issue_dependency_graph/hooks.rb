module IssueDependencyGraph
	class Hooks < Redmine::Hook::ViewListener
		render_on :view_versions_show_contextual,
		          :partial => 'hooks/issue_dependency_graph/view_versions_show_contextual'

		render_on :view_issues_sidebar_issues_bottom,
		          :partial => 'hooks/issue_dependency_graph/view_issues_sidebar_issues_bottom'
	end
end

