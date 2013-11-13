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
  window.editor = CodeMirror.fromTextArea($('#run_query_sql')[0], {
    mode: 'text/x-sql',
    indentWithTabs: true,
    smartIndent: true,
    lineNumbers: true,
    matchBrackets : true,
    autofocus: true
  });

//  success: function(data, status, xhr) {
//    element.trigger('ajax:success', [data, status, xhr]);
//  },
//  complete: function(xhr, status) {
//    element.trigger('ajax:complete', [xhr, status]);
//  },
//  error: function(xhr, status, error) {
//    element.trigger('ajax:error', [xhr, status, error]);
//  },

  // TODO: error handling
  $(document).on('ajax:success', '#query-container form', function (event, data, status, xhr) {
    $('#query-results-container').html(data);
  });

  $(document).on('ajax:success', '#saved-queries a', function (event, data, status, xhr) {
    $('#query-container .run_query_sql .help-block').html(data.description);
    window.editor.setValue(data.sql);
  });
});
