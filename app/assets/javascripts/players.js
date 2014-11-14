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

/*
  $("#generate-lineup").click(function() {

    var game_ids = [];
    $('.ginfo:checked').each(function() {
      game_ids.push($(this).data('gid'));
    });

    var data = {};
    data.year = parseInt($("#date-info").data('year'), 10);
    data.month = parseInt($("#date-info").data('month'), 10);
    data.day = parseInt($("#date-info").data('day'), 10);
    data.games = game_ids;
    $.ajax({
      url: '/lineups',
      type: 'GET',
      data: data,
      async: true,
      dataType: "json",
      success: function (data) {
        best = data[0];
        secondary = data[1];
        $("#lineup-salary").text(best.salary);
        $("#lineup-expected-points").text(best.expected_points);
        $("#lineup-actual-points-dk").text(best.actual_points_dk);

        var p = best.players.point_guard;
        $("#lineup-pg").find(".name").text(p.player.full_name);
        $("#lineup-pg").find(".salary").text(p.salary);
        $("#lineup-pg").find(".expected-points").text(p.expected_points);

        p = best.players.shooting_guard;
        $("#lineup-sg").find(".name").text(p.player.full_name);
        $("#lineup-sg").find(".salary").text(p.salary);
        $("#lineup-sg").find(".expected-points").text(p.expected_points);

        p = best.players.small_forward;
        $("#lineup-sf").find(".name").text(p.player.full_name);
        $("#lineup-sf").find(".salary").text(p.salary);
        $("#lineup-sf").find(".expected-points").text(p.expected_points);

        p = best.players.power_forward;
        $("#lineup-pf").find(".name").text(p.player.full_name);
        $("#lineup-pf").find(".salary").text(p.salary);
        $("#lineup-pf").find(".expected-points").text(p.expected_points);

        p = best.players.center;
        $("#lineup-c").find(".name").text(p.player.full_name);
        $("#lineup-c").find(".salary").text(p.salary);
        $("#lineup-c").find(".expected-points").text(p.expected_points);

        p = best.players.guard;
        $("#lineup-g").find(".name").text(p.player.full_name);
        $("#lineup-g").find(".salary").text(p.salary);
        $("#lineup-g").find(".expected-points").text(p.expected_points);

        p = best.players.forward;
        $("#lineup-f").find(".name").text(p.player.full_name);
        $("#lineup-f").find(".salary").text(p.salary);
        $("#lineup-f").find(".expected-points").text(p.expected_points);

        p = best.players.utility;
        $("#lineup-u").find(".name").text(p.player.full_name);
        $("#lineup-u").find(".salary").text(p.salary);
        $("#lineup-u").find(".expected-points").text(p.expected_points);

        $("#lineup-salary2").text(secondary.salary);
        $("#lineup-expected-points2").text(secondary.expected_points);
        $("#lineup-actual-points-dk2").text(secondary.actual_points_dk);

        p = secondary.players.point_guard;
        $("#lineup-pg2").find(".name").text(p.player.full_name);
        $("#lineup-pg2").find(".salary").text(p.salary);
        $("#lineup-pg2").find(".expected-points").text(p.expected_points);

        p = secondary.players.shooting_guard;
        $("#lineup-sg2").find(".name").text(p.player.full_name);
        $("#lineup-sg2").find(".salary").text(p.salary);
        $("#lineup-sg2").find(".expected-points").text(p.expected_points);

        p = secondary.players.small_forward;
        $("#lineup-sf2").find(".name").text(p.player.full_name);
        $("#lineup-sf2").find(".salary").text(p.salary);
        $("#lineup-sf2").find(".expected-points").text(p.expected_points);

        p = secondary.players.power_forward;
        $("#lineup-pf2").find(".name").text(p.player.full_name);
        $("#lineup-pf2").find(".salary").text(p.salary);
        $("#lineup-pf2").find(".expected-points").text(p.expected_points);

        p = secondary.players.center;
        $("#lineup-c2").find(".name").text(p.player.full_name);
        $("#lineup-c2").find(".salary").text(p.salary);
        $("#lineup-c2").find(".expected-points").text(p.expected_points);

        p = secondary.players.guard;
        $("#lineup-g2").find(".name").text(p.player.full_name);
        $("#lineup-g2").find(".salary").text(p.salary);
        $("#lineup-g2").find(".expected-points").text(p.expected_points);

        p = secondary.players.forward;
        $("#lineup-f2").find(".name").text(p.player.full_name);
        $("#lineup-f2").find(".salary").text(p.salary);
        $("#lineup-f2").find(".expected-points").text(p.expected_points);

        p = secondary.players.utility;
        $("#lineup-u2").find(".name").text(p.player.full_name);
        $("#lineup-u2").find(".salary").text(p.salary);
        $("#lineup-u2").find(".expected-points").text(p.expected_points);
      }

    });


  });
*/

});
  var nbaApp = angular.module('nbaApp', []);

  nbaApp.controller('GameDayCtrl', function ($scope, $http) {

    $scope.generateLineups = function () {

      $scope.lineup1 = null;
      $scope.lineup2 = null;

      var game_ids = [];
      $('.ginfo:checked').each(function() {
        game_ids.push($(this).data('gid'));
      });

      var data = {};
      data.year = $("#date-info").data('year');
      data.month = $("#date-info").data('month');
      data.day = $("#date-info").data('day');
      data.games = game_ids;

      $http.get("/lineups?" + $.param(data)).
        success(function(data, status, headers, config) {
          $scope.lineup1 = data[0];
          $scope.lineup2 = data[1];
        });

    };

  });
