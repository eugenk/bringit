$.fn.editFile = function() {
	$(this).unbind('click').click(function(e) {
		// Setup buttons and show edit form
    	e.preventDefault();
    	$(this).addClass("update-file btn-primary");
    	$(this).html($(this).data("replace"));
    	editor.setOption("readOnly", false);
    	$(".hidden-options").slideDown();
    	$(this).after('<a href="#" class="btn btn-inverse edit-cancel"><i class="icon-remove"></i> Cancel</a>');
    	
    	// Submit form by clicking
    	$(this).unbind('click').click(function() {
    		$("form.edit-form").submit();
    		return false;
    	});
    	
    	// Cancel Button (rollback)
    	$('.edit-cancel').unbind('click').click(function() {
    		$(this).remove();
    		$('.update-file').removeClass("update-file btn-primary").html('<i class="icon-edit"></i> Edit');
    		editor.setOption("readOnly", true);
    		$(".hidden-options").slideUp();
    		$(".edit-file").editFile();
    		return false;
    	});
    	
    	// Commit message required
    	$('.edit-form').unbind('submit').submit(function() {
    		if($.trim($('#message').val()) == '') {
    			$('.alert').remove();
    			$('#message').before('<div class="alert alert-error">Please enter a commit message.</div>');
    			return false;
    		} else {
    			return true;
    		}
    	});
    	
    	return false;
    	
    });
	return this;
};