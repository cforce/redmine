// TODO: JSUnit test this
jQuery(document).ready(function(){
  attachSortables();

  jQuery("#user_id").change(function() {
    jQuery("form#user_switch").submit();
  });
  jQuery("#ajax-indicator").ajaxStart(function(){
    jQuery(this).show();
  });
  jQuery("#ajax-indicator").ajaxStop(function(){
    jQuery(this).hide();
  });

  jQuery("#filter").change(function() {
    if (jQuery('#filter').val() != '') {
      jQuery.ajax({
        type: "GET",
        url: location.pathname +'/available_issues.js',
        data: jQuery('#filter').serialize(),
        success: function(response) {
          jQuery('#available-pane').html(response);
          attachSortables();
        },
        error: function(response) {
          jQuery("div.error").html("Error filtering pane.  Please refresh the page.").show();
        }
      });
    }
  });

});

function attachSortables() {

  jQuery("#doing-now").sortable({
    //    connectWith: ["#available", "#recommended"],
    dropOnEmpty: true,
    placeholder: 'drop-accepted',
    update : function (event, ui) {
      saveOrder(ui);
    }
  });

}

function saveOrder() {
  data = 'user_id=' + user_id + '&' + jQuery("#doing-now").sortable('serialize');
  if (filter != null) {
    data = data + '&filter=' + filter;
  }
  
  jQuery.ajax({
    type: "POST",
    url: location.pathname +'/reorder.js',
    data: data,
    async: false,
    success: function(response) {
      jQuery('#content').html(response);
      updateStopwatches();
      updateDoingIssuesState();
      attachSortables();
    },
    complete:function(){
      updateStopwatches();
    },
    error: function(response) {
      jQuery("div.error").html("Error saving lists.  Please refresh the page and try again.").show();
    }
  });
}

attachSortables();