$.fn.replaceAjax = function() {
	$(this).data('type', 'html')
	.on('ajax:success', function(event, data) {
		var $this = $(this);
		$($this.data('replace')).html(data);
		$this.trigger('ajax:replaced');
	  
		$($(this).data("update")).modal('show');

		$($(this).data("update")).find("input[type=text], select, textarea, input[password]").first().focus();
		$('[data-remote][data-replace]').replaceAjax();
	});	
	return this;
};