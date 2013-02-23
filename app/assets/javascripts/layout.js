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
});

