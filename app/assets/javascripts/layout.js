$('alert').alert();

$('#term').bind('railsAutocomplete.select', function(event, data){
	window.location.href = Routes.repository_path(data.item.path);
});


function setupAjax() {
	$('[data-remote][data-replace]')
	.data('type', 'html')
	.on('ajax:success', function(event, data) {
		var $this = $(this);
		$($this.data('replace')).html(data);
		$this.trigger('ajax:replaced');
	  
		$($(this).data("update")).modal('show');

		$($(this).data("update")).find("input[type=text], select, textarea, input[password]").first().focus();
		setupAjax();
	});
}




function initCreateModal() {
	$('.create-confirm').click(function(e) {
		e.preventDefault();
		$('#create-confirm').modal('show');
		return false;
	});
}


$(function() {
  	setupAjax();
  	$('#delete-confirm').on('show', function() {
		$(this).find('.btn-danger').attr('href', $(this).data('url'));
		$(this).find('h3').html($(this).data('head'));
		$(this).find('.modal-body p').html($(this).data('confirm'));
	});
  	$('.delete-confirm').click(function(e) {
		e.preventDefault();
		$('#delete-confirm').data('id', $(this).data('id')).data('url', $(this).attr("href")).data('head', $(this).data('head')).data('confirm', $(this).data('confirm')).modal('show');
		return false;
	});
	$(".best_in_place").best_in_place();
	$('.repository-title span.changeable-title').click(function() {
		$(this).hide();
		$('#edit-title-form').show();
		$('#edit-title-form').find('input[type=text]').val($(this).text());
		$('#edit-title-form').find('input[type=text]').focus();
	});
	initCreateModal();
	$('[data-toggle=tooltip]').tooltip({placement: 'left'});
	
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
	
	$(".message .open-full").click(function() {
		var msg = $(this).parentsUntil(".message").parent();
		msg.find(".full-message").slideToggle();
		$(this).find("i").toggleClass("icon-minus");
		return false;
	});
});

$.fn.relatizeTimestamps = function() {
  $(this).find(".timestamp").each(function() {
    var $this, time;
    $this = $(this);
    time = moment($this.text());
    return $this.text(time.fromNow()).attr("title", time.format("LLLL"));
  });
  return this;
};

$(function() {
  return $("body").relatizeTimestamps();
});

(function() {
var uv = document.createElement('script'); uv.type = 'text/javascript'; uv.async = true;
uv.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + 'fruitback.digineo.de/customer_sites/2/widget.js';var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(uv, s);
})();
