$(function() {
	// Render last commit, for better performance
	if($(".file-table").length > 0) {
		var table = $(".file-table");
		$.ajax({
			type: "GET",
			url: Routes.entries_path(table.data('repository')),	
			dataType: "json",
			data: {
				url: table.data('url'),
				oid: table.data('oid')
			}	
		}).done(function(list) {
			$.each(list, function(key, value) {
				table.find("tr[data-id="+key+"] td.last-modified").html('<span class="timestamp">'+value.committer_time+'</span>').relatizeTimestamps();
				var html = '<a href="'+Routes.browse_commits_root_path(table.data('repository'), value.oid)+'">';
				html += value.message;
				html += '</a>';
				html += ' ['+value.committer_name+']';
				table.find("tr[data-id="+key+"] td.last-commit").html(html);
			});
			$(".file-table tr td.last-commit a").truncate({
			    width: 400,
				token: '&hellip;'
			});
		});	
	}
});