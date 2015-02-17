module IssueDependencyGraph
	class Hooks < Redmine::Hook::ViewListener
		render_on :view_versions_show_contextual,
		          :partial => 'hooks/issue_dependency_graph/view_versions_show_contextual'

		render_on :view_issues_show_details_bottom,
		          :partial => 'hooks/issue_dependency_graph/view_issues_show_details_bottom'
	end
end

