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
	  $($(this).data("update")).fadeIn();
	  $($(this).data("update")).find("input[type=text], select, textarea, input[password]").first().focus();
	  $("button.close").click(function() {
	  	$(this).parentsUntil("#modal").parent().fadeOut();
	  	return false;
	  });  
	  setupAjax();
	});
}

$(function() {
  setupAjax();
});

