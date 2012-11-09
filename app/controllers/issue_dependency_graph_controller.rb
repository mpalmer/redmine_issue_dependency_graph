class IssueDependencyGraphController < ApplicationController
	unloadable

	def version_graph
		all_issues = {}

		Issue.find_all_by_fixed_version_id(params[:version]).each do |i|
			all_issues[i.id] = i
		end

		relevant_issues = []
		relations = []

		IssueRelation.find(:all).each do |ir|
			if all_issues[ir.issue_from_id] and all_issues[ir.issue_to_id]
				relations << { :from => ir.issue_from_id, :to => ir.issue_to_id, :type => ir.relation_type }
				relevant_issues << all_issues[ir.issue_from_id]
				relevant_issues << all_issues[ir.issue_to_id]
			end
		end

		all_issues.values.each do |i|
			if i.parent_id and all_issues[i.id] and all_issues[i.parent_id]
				relations << { :from => i.parent_id, :to => i.id, :type => 'child' }
				relevant_issues << all_issues[i.id]
				relevant_issues << all_issues[i.parent_id]
			end
		end

		render_graph(relevant_issues, relations)
	end

	def issue_graph
		pending_issues = [Issue.find(params[:issue])]
		relevant_issues = []
		relations = []

		until pending_issues.empty?
			i = pending_issues.shift
			relevant_issues << i

			rels = i.relations.map { |ir| { :from => ir.issue_from_id, :to => ir.issue_to_id, :type => ir.relation_type } }
			if i.parent_id
				rels << { :from => i.parent_id, :to => i.id, :type => 'child' }
			end
			Issue.find_all_by_parent_id(i.id).each do |child|
				rels << { :from => i.id, :to => child.id, :type => 'child' }
			end

			rels.each do |ir|
				if ir[:from] == i.id
					other_issue = ir[:to]
					relations << ir
				else
					other_issue = ir[:from]
				end

				if relevant_issues.select { |ri| ri.id == other_issue }.empty?
					pending_issues << Issue.find(other_issue)
				else
					# We've already processed the other issue in
					# this relationship
					next
				end
			end

			pending_issues.uniq!
		end

		render_graph(relevant_issues, relations)
	end

	private
	def render_graph(issues, relations)
		png = nil

		IO.popen("unflatten | dot -Tpng", "r+") do |io|
			io.binmode
			io.puts "digraph redmine {"
			issues.uniq.each do |i|
				colour = i.closed? ? 'grey' : 'black'
				io.puts "#{i.id} [label=\"##{i.id}: #{render_title(i)}\", fontcolor=#{colour}]"
			end

			relations.each do |ir|
				# http://www.redmine.org/projects/redmine/wiki/Rest_IssueRelations
				# sez that relations can either be 'relates', 'blocks', or 'precedes'
				# I add 'child', because that's how I roll.
				io.puts case ir[:type]
					when 'blocks'   then "#{ir[:to]} -> #{ir[:from]} [style=solid,  color=red dir=back]"
					when 'precedes' then "#{ir[:to]} -> #{ir[:from]} [style=solid,  color=black dir=back]"
					when 'relates'  then "#{ir[:from]} -> #{ir[:to]} [style=dotted, color=black dir=none]"
					when 'child'    then "#{ir[:from]} -> #{ir[:to]} [style=dashed, color=grey]"
					else "#{ir[:from]} -> #{ir[:to]} [style=bold, color=pink]"
				end
			end

			io.puts "}"
			io.close_write
			png = io.read
		end
		send_data png, :type => 'image/png', :filename => 'graph.png', :disposition => 'inline'
	end

	def render_title(i)
		i.subject.chomp.gsub(/((?:[^ ]+ ){4})/, "\\1\\n").gsub('"', '\\"')
	end
end

