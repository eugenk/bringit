$('alert').alert();

$('#term').bind('railsAutocomplete.select', function(event, data){
	window.location.href = Routes.repository_path(data.item.id);
});
