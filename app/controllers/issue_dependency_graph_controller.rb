class IssueDependencyGraphController < ApplicationController
	unloadable

	def graph
		all_issues = {}

		Issue.find_all_by_fixed_version_id(params[:version]).each do |i|
			all_issues[i.id] = {:title => i.subject.chomp.gsub(/((?:[^ ]+ ){4})/, "\\1\\n").gsub('"', '\\"'),
			                    :object => i
			                   }
		end

		relevant_issues = {}
		relations = []

		IssueRelation.find(:all).each do |ir|
			if all_issues.keys.include?(ir.issue_from_id) and all_issues.keys.include?(ir.issue_to_id)
				relations << { :from => ir.issue_from_id, :to => ir.issue_to_id, :type => ir.relation_type }
				relevant_issues[ir.issue_from_id] = all_issues[ir.issue_from_id]
				relevant_issues[ir.issue_to_id]   = all_issues[ir.issue_to_id]
			end
		end

		all_issues.values.each do |i|
			if i[:object].parent_id
				relations << { :from => i[:object].parent_id, :to => i[:object].id, :type => 'child' }
				relevant_issues[i[:object].id]        = all_issues[i[:object].id]
				relevant_issues[i[:object].parent_id] = all_issues[i[:object].parent_id]
			end
		end


		png = nil

		IO.popen("dot -Tpng", "r+") do |io|
			io.binmode
			io.puts "digraph redmine {"
			relevant_issues.each do |id, i|
				colour = i[:object].closed? ? 'grey' : 'black'
				io.puts "#{id} [label=\"##{id}: #{i[:title]}\", fontcolor=#{colour}]"
			end

			relations.each do |ir|
				# http://www.redmine.org/projects/redmine/wiki/Rest_IssueRelations
				# sez that relations can either be 'relates', 'blocks', or 'precedes'
				# I add 'child', because that's how I roll.
				style = case ir[:type]
					when 'blocks'   then '[style=solid,  color=red]'
					when 'precedes' then '[style=solid,  color=black]'
					when 'relates'  then '[style=dotted, color=black]'
					when 'child'    then '[style=dashed, color=grey]'
					else '[style=bold, color=pink]'
				end
				io.puts "#{ir[:from]} -> #{ir[:to]} #{style}"
			end

			io.puts "}"
			io.close_write
			png = io.read
		end
		send_data png, :type => 'image/png', :filename => 'graph.png', :disposition => 'inline'
	end
end

