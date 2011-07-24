$(function() {

  // initialize scrollable
  $(".scrollable").scrollable();
  
  $('a.next').live('click', function() {
    var api = $(".scrollable").data("scrollable");
    $.get("/products/next/"+api.getIndex(), function(data) {
      api.addItem(data);
      $("#page_number").html(api.getIndex()+1);
      // $('.items').append(data);
      // $(".scrollable").scrollable();
      
      
    })
  })
  
  $('a.prev').live('click', function(){
    var api = $(".scrollable").data("scrollable");
    $("#page_number").html(api.getIndex()+1);
  })
});