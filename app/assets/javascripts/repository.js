// TODO Dynamic loading (requirejs? + mime_type to codemirror helper)
//= require codemirror/modes/apl
//= require codemirror/modes/asterisk
//= require codemirror/modes/clike
//= require codemirror/modes/clojure
//= require codemirror/modes/coffeescript
//= require codemirror/modes/commonlisp
//= require codemirror/modes/css
//= require codemirror/modes/d
//= require codemirror/modes/diff
//= require codemirror/modes/ecl
//= require codemirror/modes/erlang
//= require codemirror/modes/gfm
//= require codemirror/modes/go
//= require codemirror/modes/groovy
//= require codemirror/modes/haskell
//= require codemirror/modes/haxe
//= require codemirror/modes/htmlembedded
//= require codemirror/modes/htmlmixed
//= require codemirror/modes/http
//= require codemirror/modes/javascript
//= require codemirror/modes/jinja2
//= require codemirror/modes/less
//= require codemirror/modes/lua
//= require codemirror/modes/markdown
//= require codemirror/modes/mysql
//= require codemirror/modes/ntriples
//= require codemirror/modes/ocaml
//= require codemirror/modes/pascal
//= require codemirror/modes/perl
//= require codemirror/modes/php
//= require codemirror/modes/pig
//= require codemirror/modes/plsql
//= require codemirror/modes/properties
//= require codemirror/modes/python
//= require codemirror/modes/r
//= require codemirror/modes/rst
//= require codemirror/modes/ruby
//= require codemirror/modes/rust
//= require codemirror/modes/sass
//= require codemirror/modes/scheme
//= require codemirror/modes/shell
//= require codemirror/modes/sieve
//= require codemirror/modes/smalltalk
//= require codemirror/modes/smarty
//= require codemirror/modes/sparql
//= require codemirror/modes/sql
//= require codemirror/modes/stex
//= require codemirror/modes/tiddlywiki
//= require codemirror/modes/tiki
//= require codemirror/modes/vb
//= require codemirror/modes/vbscript
//= require codemirror/modes/velocity
//= require codemirror/modes/verilog
//= require codemirror/modes/xml
//= require codemirror/modes/xquery
//= require codemirror/modes/yaml
//= require codemirror/modes/z80

$(function() {
    // Setup codemirror highlighting
	if($("#code-area").length > 0) {
	   	editor = CodeMirror.fromTextArea(document.getElementById("code-area"), {
	      mode: $("#code-area").data("mime-type"),
	      lineNumbers: true,
	      readOnly: true
	    });
		// Setup edit form
		$(".edit-file").editFile();
	}
});