$(document).ready(function() {

});

  var nbaApp = angular.module('nbaApp', []);

  nbaApp.controller('GameDayCtrl', function ($scope, $http) {

    $scope.getPlayerCosts = function() {
      var data = {};
      data.year = parseInt($("#date-info").data('year'), 10);
      data.month = parseInt($("#date-info").data('month'), 10);
      data.day = parseInt($("#date-info").data('day'), 10);
      $http.get("/player_costs?" + $.param(data)).
        success(function(data, status, headers, config) {
          $scope.players = data;
        });
    };

    $scope.getPlayerCosts();

    $scope.playerLock = function(player) {
      var data = {};
      data.year = parseInt($("#date-info").data('year'), 10);
      data.month = parseInt($("#date-info").data('month'), 10);
      data.day = parseInt($("#date-info").data('day'), 10);
      data.locked = true;
      $http.put("/player_costs/" + player.id, data).
        success(function(data, status, headers, config) {
          $scope.players.splice($scope.players.indexOf(player),1);
          $scope.players.push(data[0]);
        });
    };

    $scope.playerUnlock = function(player) {
      var data = {};
      data.year = parseInt($("#date-info").data('year'), 10);
      data.month = parseInt($("#date-info").data('month'), 10);
      data.day = parseInt($("#date-info").data('day'), 10);
      data.locked = false;
      $http.put("/player_costs/" + player.id, data).
        success(function(data, status, headers, config) {
          $scope.players.splice($scope.players.indexOf(player),1);
          $scope.players.push(data[0]);
        });
    };

    $scope.playerOut = function(player) {
      var data = {};
      data.year = parseInt($("#date-info").data('year'), 10);
      data.month = parseInt($("#date-info").data('month'), 10);
      data.day = parseInt($("#date-info").data('day'), 10);
      data.healthy = false;
      $http.put("/player_costs/" + player.id, data).
        success(function(data, status, headers, config) {
          $scope.players.splice($scope.players.indexOf(player),1);
          $scope.players.push(data[0]);
        });
    };

    $scope.playerIn = function(player) {
      var data = {};
      data.year = parseInt($("#date-info").data('year'), 10);
      data.month = parseInt($("#date-info").data('month'), 10);
      data.day = parseInt($("#date-info").data('day'), 10);
      data.healthy = true;
      $http.put("/player_costs/" + player.id, data).
        success(function(data, status, headers, config) {
          $scope.players.splice($scope.players.indexOf(player),1);
          $scope.players.push(data[0]);
        });
    };


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
      data.starters = $(".only-starters").prop('checked');

      $http.get("/lineups?" + $.param(data)).
        success(function(data, status, headers, config) {
          $scope.lineup1 = data[0];
          $scope.lineup2 = data[1];
        });
    };

  });
