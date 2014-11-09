$(document).ready(function() {

  $(document).on('click', ".pc-out", function() {
    var table_row = $(this).parent().parent();
    var pcid = parseInt($(this).parent().parent().attr('pcid'), 10);
    var data = {};
    data.healthy = false;
    $.ajax({
      url: '/player_costs/' + pcid,
      type: 'PUT',
      data: data,
      async: true,
      dataType: "json",
      success: function (data) {
        var moved_expected_points = parseFloat(table_row.find(".pc-expected-points").text(), 10);
        var other_table = $(".pcs-unhealthy");
        var found_slot = false;

        var btn = table_row.find(".pc-out");
        btn.removeClass("pc-out").addClass("pc-in");
        btn.text('In');

        other_table.children().each(function() {
          var expected_points = parseInt($(this).find(".pc-expected-points").text(),10);
          if (expected_points < moved_expected_points) {
            $(this).before(table_row);
            found_slot = true;
            return false;
          }
        });
        if (!found_slot) {
          table_row.appendTo(other_table);
        }
      }
    });
  });

  $(document).on('click', ".pc-in", function() {
    var table_row = $(this).parent().parent();
    var pcid = parseInt($(this).parent().parent().attr('pcid'), 10);
    var data = {};
    data.healthy = true;
    $.ajax({
      url: '/player_costs/' + pcid,
      type: 'PUT',
      data: data,
      async: true,
      dataType: "json",
      success: function (data) {
        var moved_expected_points = parseFloat(table_row.find(".pc-expected-points").text(), 10);
        var other_table = $(".pcs-healthy");

        var btn = table_row.find(".pc-in");
        btn.removeClass("pc-in").addClass("pc-out");
        btn.text('Out');

        var found_slot = false;
        other_table.children().each(function() {
          var expected_points = parseInt($(this).find(".pc-expected-points").text(),10);
          if (expected_points < moved_expected_points) {
            $(this).before(table_row);
            found_slot = true;
            return false;
          }
        });
        //check if inputted, and if not, put at the end of the table
        //this should actually work for the case with no children too
        if (!found_slot) {
          table_row.appendTo(other_table);
        }
      }
    });
  });


});

