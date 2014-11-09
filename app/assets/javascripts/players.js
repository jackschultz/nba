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


  $("#generate-lineup").click(function() {
    var data = {};
    data.year = parseInt($("#date-info").data('year'), 10);
    data.month = parseInt($("#date-info").data('month'), 10);
    data.day = parseInt($("#date-info").data('day'), 10);
    $.ajax({
      url: '/lineups',
      type: 'GET',
      data: data,
      async: true,
      dataType: "json",
      success: function (data) {
        $("#lineup-salary").text(data.salary);
        $("#lineup-expected-points").text(data.expected_points);

        var p = data.players.point_guard;
        $("#lineup-pg").find(".name").text(p.player.full_name);
        $("#lineup-pg").find(".salary").text(p.salary);
        $("#lineup-pg").find(".expected-points").text(p.expected_points);

        p = data.players.shooting_guard;
        $("#lineup-sg").find(".name").text(p.player.full_name);
        $("#lineup-sg").find(".salary").text(p.salary);
        $("#lineup-sg").find(".expected-points").text(p.expected_points);

        p = data.players.small_forward;
        $("#lineup-sf").find(".name").text(p.player.full_name);
        $("#lineup-sf").find(".salary").text(p.salary);
        $("#lineup-sf").find(".expected-points").text(p.expected_points);

        p = data.players.power_forward;
        $("#lineup-pf").find(".name").text(p.player.full_name);
        $("#lineup-pf").find(".salary").text(p.salary);
        $("#lineup-pf").find(".expected-points").text(p.expected_points);

        p = data.players.center;
        $("#lineup-c").find(".name").text(p.player.full_name);
        $("#lineup-c").find(".salary").text(p.salary);
        $("#lineup-c").find(".expected-points").text(p.expected_points);

        p = data.players.guard;
        $("#lineup-g").find(".name").text(p.player.full_name);
        $("#lineup-g").find(".salary").text(p.salary);
        $("#lineup-g").find(".expected-points").text(p.expected_points);

        p = data.players.forward;
        $("#lineup-f").find(".name").text(p.player.full_name);
        $("#lineup-f").find(".salary").text(p.salary);
        $("#lineup-f").find(".expected-points").text(p.expected_points);

        p = data.players.utility;
        $("#lineup-u").find(".name").text(p.player.full_name);
        $("#lineup-u").find(".salary").text(p.salary);
        $("#lineup-u").find(".expected-points").text(p.expected_points);
      }
    });


  });

});

