$(function() {

  var scrollable = $(".scrollable");
  var total_pages = parseInt($('.total_pages').text());

  // initialize scrollable
  scrollable.scrollable();
  
  $('a.next, a.prev').live('click.scrollable', function(e) {
    var api = scrollable.data("scrollable");
    $("#page_number").html(api.getIndex()+1);
  });

});