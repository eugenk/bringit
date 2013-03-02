$(function() {
	// Bootstrap Alerts
	$('alert').alert();
	
	// Bootstrap Tooltip
	$('[data-toggle=tooltip]').tooltip({placement: 'left'});
	
	// Replace containers with ajax
  	$('[data-remote][data-replace]').replaceAjax();
  	
  	// Redirect when select autocomplete value in search
  	$('#term').bind('railsAutocomplete.select', function(event, data){
		window.location.href = Routes.repository_path(data.item.path);
	});
  	
  	// Best in place
	$(".best_in_place").best_in_place();
	
	// Best in place with redirect
	$('.repository-title span.changeable-title').click(function() {
		$(this).hide();
		$('#edit-title-form').show();
		$('#edit-title-form').find('input[type=text]').val($(this).text());
		$('#edit-title-form').find('input[type=text]').focus();
	});
	
	// Slidetoggle for commit message
	$(".message .open-full").click(function() {
		var msg = $(this).parentsUntil(".message").parent();
		msg.find(".full-message").slideToggle();
		$(this).find("i").toggleClass("icon-minus");
		return false;
	});
	
	// Render time ago with javascript
	$("body").relatizeTimestamps();
});


// Fruitback
(function() {
var uv = document.createElement('script'); uv.type = 'text/javascript'; uv.async = true;
uv.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + 'fruitback.digineo.de/customer_sites/2/widget.js';var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(uv, s);
})();