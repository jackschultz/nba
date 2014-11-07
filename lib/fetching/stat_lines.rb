require "faraday"
require "faraday_middleware"
require "net/http"
require "nokogiri"
require "json"

module Fetching
  class StatLines < NbaApi

    def self.process_stat_lines(game_id)
      #game_id must be string of length 10, 0 padded at front
      game = Game.find(game_id)
      if game.nil?
        Rails.logger.warn "No game with nba id #{game_id}"
        return
      end
      Rails.logger.info "Fetching stat lines for game: #{game_id}"
      url = 'http://stats.nba.com/stats/boxscore/'
      params = {}
      params['GameID'] = game.nba_id
      params['StartRange'] = 0
      params['EndRange'] = 0
      params['StartPeriod'] = 0
      params['EndPeriod'] = 0
      params['RangeType'] = 0
      resp = fetch_from_nba(url, params)
      if resp
        result = JSON.parse(resp)['resultSets']
        game_stat_lines = result[4]['rowSet']
        game_stat_lines.each do |game_stat|
          player = Player.find_by_nba_id(game_stat[4])
          team = Team.find_by_nba_id(game_stat[1])
          #we need to check to see if team has all the fields
          if player.nil?
            #now we want to create the player? This could be the easy way to load players...
            names = game_stat[5].split(' ')
            first_name = names[0]
            last_name = names[1..-1].join(' ')
            underscored_name = "#{first_name.downcase}_#{last_name.downcase}"
            player = Player.create(underscored_name: underscored_name,first_name: first_name, last_name: last_name, nba_id: game_stat[4], team: team)
            Rails.logger.info "New player created Fetching::BoxScores.process_box_score: #{player.inspect}"
          else
            #we want to check to see what team the player is on. We want to change it
            #if this game is the latest game the player has played, set the team (current)
            #as this
          end
          stat_line = record_player_game_stat(player, game, team, game_stat)
          record_actual_points(stat_line)
        end
      else
        Rails.logger.info "Bad response from nba Fetching::BoxScores.process_box_score"
      end
    end

    def self.record_actual_points(stat_line)
      player_costs = stat_line.game.player_costs.find_by_player_id(stat_line.player.id)
      if !player_costs.nil?
        player_costs.each do |pc|
          pc.actual_cost_dk = stat_line.score_draft_kings
        end
      end
    end

    def self.record_player_game_stat(player, game, team, row)
      stat_line = StatLine.where(player_id: player.id, game_id: game.id, team_id: team.id).first_or_create
      stat_line.minutes = row[8]
      stat_line.fgm = row[9]
      stat_line.fga = row[10]
      stat_line.fg_pct = row[11]
      stat_line.fg3m = row[12]
      stat_line.fg3a = row[13]
      stat_line.fg3_pct = row[14]
      stat_line.ftm = row[15]
      stat_line.fta = row[16]
      stat_line.ft_pct = row[17]
      stat_line.oreb = row[18]
      stat_line.dreb = row[19]
      stat_line.reb = row[20]
      stat_line.ast = row[21]
      stat_line.to = row[22]
      stat_line.stl = row[23]
      stat_line.blk = row[24]
      stat_line.pf = row[25]
      stat_line.pts = row[26]
      stat_line.plus_minus = row[27]
      stat_line.save
      stat_line
    end

  end
end

