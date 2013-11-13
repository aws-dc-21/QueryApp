// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require codemirror
//= require codemirror/modes/sql
//= require_tree .

$(function() {
  $('[data-toggle="tooltip"]').tooltip();

  var $editorField = ($('#saved_query_sql')[0] || $('#run_query_sql')[0]);

  window.editor = CodeMirror.fromTextArea($editorField, {
    mode: 'text/x-sql',
    indentWithTabs: true,
    smartIndent: true,
    lineNumbers: true,
    matchBrackets : true,
    autofocus: true
  });

  var $document = $(document);

  $document.on('click', '#query-container form input[type="submit"]', function (event) {
    var $this = $(this),
      csvDownload = $this.val().match(/CSV/),
      remote = !csvDownload;

    if (remote) {
      event.preventDefault();
      // CodeMirror doesn't seem to set the value when preventDefault is called, so we have to do that manually
      $('#query-container #run_query_sql').val(window.editor.getValue());
      $.rails.handleRemote($this.closest('form'));
    }
  });

  $document.on('click', '#save-as', function (event) {
    var $this = $(this),
      href = $this.attr('href'),
      newHref = href.replace('__SQL__', window.editor.getValue());

    $this.attr('href', newHref);
  });

  // TODO: error handling
  $document.on('ajax:success', '#query-container form', function (event, data, status, xhr) {
    $('#query-results-container').html(data);
  });

  $document.on('ajax:success', '#saved-queries a', function (event, data, status, xhr) {
    $('#query-container .run_query_sql .help-block').html(data.description);
    window.editor.setValue(data.sql);
  });
});
