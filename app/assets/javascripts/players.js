  var optimize = function(player_hash) {

    var dominators = {};
  };

  var nbaApp = angular.module('nbaApp', []);

  nbaApp.controller('GameDayCtrl', ['$scope', '$http', function ($scope, $http) {

    $scope.getPlayerCosts = function() {
      var site_id = parseInt($("#site-info").data('site-id'), 10);
      var data = {};
      data.year = parseInt($("#date-info").data('year'), 10);
      data.month = parseInt($("#date-info").data('month'), 10);
      data.day = parseInt($("#date-info").data('day'), 10);
      $http.get("/site/" + site_id + "/player_costs?" + $.param(data)).
        success(function(data, status, headers, config) {
          $scope.players = data;
          for (var i = 0; i < data.length; i++) {
            $scope.players[i].locked = false;
          }
        });
    };

    $scope.getPlayerCosts();

    $scope.locked_players = [];

    $scope.playerLock = function(player) {
      player.locked = true;
    };

    $scope.playerUnlock = function(player) {
      player.locked = false;
    };

    $scope.playerOut = function(player) {
      var site_id = parseInt($("#site-info").data('site-id'), 10);
      var data = {};
      data.year = parseInt($("#date-info").data('year'), 10);
      data.month = parseInt($("#date-info").data('month'), 10);
      data.day = parseInt($("#date-info").data('day'), 10);
      data.healthy = false;
      $http.put("/site/" + site_id + "/player_costs/" + player.id, data).
        success(function(data, status, headers, config) {
          $scope.players.splice($scope.players.indexOf(player),1);
          $scope.players.push(data[0]);
        });
    };

    $scope.playerIn = function(player) {
      var site_id = parseInt($("#site-info").data('site-id'), 10);
      var data = {};
      data.year = parseInt($("#date-info").data('year'), 10);
      data.month = parseInt($("#date-info").data('month'), 10);
      data.day = parseInt($("#date-info").data('day'), 10);
      data.healthy = true;
      $http.put("/site/" + site_id + "/player_costs/" + player.id, data).
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

      var locked_ids = [];
      for(var i = 0; i < $scope.players.length; i++) {
        if ($scope.players[i].locked === true) {
          locked_ids.push($scope.players[i].id);
        }
      }

      var site_id = parseInt($("#site-info").data('site-id'), 10);
      var data = {};
      data.year = $("#date-info").data('year');
      data.month = $("#date-info").data('month');
      data.day = $("#date-info").data('day');
      data.games = game_ids;
      data.locks = locked_ids;

      $http.get("/site/" + site_id + "/lineups?" + $.param(data)).
        success(function(data, status, headers, config) {
          $scope.lineup1 = data[0];
          $scope.lineup2 = data[1];
        });
    };

  }]);
