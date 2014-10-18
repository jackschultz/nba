require "faraday"
require "faraday_middleware"
require "net/http"
require "nokogiri"
require "json"

module Fetching
  class BoxScores < NbaApi

    def self.process_box_score(game_id)
      #game_id must be string of length 10, 0 padded at front
      game = Game.find_by_nba_id(game_id)
      if game.nil?
        raise "No game with nba id #{game_id}"
      end
      game_id_string = game.nba_id_string
      url = 'http://stats.nba.com/stats/boxscore/'
      params = {}
      params['GameID'] = game_id_string
      params['StartRange'] = 0
      params['EndRange'] = 0
      params['StartPeriod'] = 0
      params['EndPeriod'] = 0
      params['RangeType'] = 0
      resp = fetch_from_nba(url, params)
      if resp
        result = JSON.parse(resp)['resultSets']
        player_stats = result[4]['rowSet']
        player_stats.each do |player_stat|
          player = Player.find_by_nba_id(player_stat[4])
          if player.nil?
            raise "Player not found Fetching::BoxScores.process_box_score"
          end
          record_player_game_stat(player, game, player_stat)
        end
      else
        raise "Bad response from nba Fetching::BoxScores.process_box_score"
      end
    end

    def self.record_player_game_stat(player, game, row)
      player_game_stat = PlayerGameStat.where(player_id: player.id, game_id: game.id).first_or_create
      player_game_stat.minutes = row[8]
      player_game_stat.fgm = row[9]
      player_game_stat.fga = row[10]
      player_game_stat.fg_pct = row[11]
      player_game_stat.fg3m = row[12]
      player_game_stat.fg3a = row[13]
      player_game_stat.fg3_pct = row[14]
      player_game_stat.ftm = row[15]
      player_game_stat.fta = row[16]
      player_game_stat.ft_pct = row[17]
      player_game_stat.oreb = row[18]
      player_game_stat.dreb = row[19]
      player_game_stat.rebounds = row[20]
      player_game_stat.assists = row[21]
      player_game_stat.turnovers = row[22]
      player_game_stat.steals = row[23]
      player_game_stat.blocks = row[24]
      player_game_stat.fouls = row[25]
      player_game_stat.points = row[26]
      player_game_stat.plus_minus = row[27]
      player_game_stat.save
    end

  end
end

