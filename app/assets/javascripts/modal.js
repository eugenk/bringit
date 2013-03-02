$(function() {
	// Create Modal by click
	$('.create-confirm').click(function(e) {
		e.preventDefault();
		$('#create-confirm').modal('show');
		return false;
	});
  	
  	// When showing delete-confirm
  	$('#delete-confirm').on('show', function() {
		$(this).find('.btn-danger').attr('href', $(this).data('url'));
		$(this).find('h3').html($(this).data('head'));
		$(this).find('.modal-body p').html($(this).data('confirm'));
	});
	
	// Create Modal by click
  	$('.delete-confirm').click(function(e) {
		e.preventDefault();
		$('#delete-confirm').data('id', $(this).data('id')).data('url', $(this).attr("href")).data('head', $(this).data('head')).data('confirm', $(this).data('confirm')).modal('show');
		return false;
	});
});