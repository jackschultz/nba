require "faraday"
require "faraday_middleware"
require "net/http"
require "nokogiri"
require "json"

module Fetching
  class Games < NbaApi

    def self.process_games_range(start_date, end_date, reverse = true, fetch_stat_lines = true)
      if reverse
        enumerable = end_date.downto(start_date)
      else
        enumerable = start_date.upto(end_date)
      end
      enumerable.each do |date|
        process_games(date, fetch_stat_lines)
      end
    end

    def self.process_games(date = nil, fetch_stat_lines = true)
      date ||= Time.now.strftime('%F')
      Rails.logger.info "Fetching::Games.process_games -> Processing for #{date}"
      url = 'http://stats.nba.com/stats/scoreboard/'
      params = {}
      params['LeagueID'] = '00'
      params['DayOffset'] = 0
      params['GameDate'] = date
      resp = fetch_from_nba(url, params)
      if resp
        result = JSON.parse(resp)['resultSets']
        ginfo = result[0]
        #tinfo = result[1]
        #game info
        ginfo['rowSet'].each do |g|
          game_date = Date.parse(g[0])
          game_nba_id = g[2]
          home_team_id = g[6].to_i
          home_team = Team.find_by_nba_id(home_team_id)
          if home_team.nil?
            Rails.logger.info "Can't find home team by nba id Fetching::Games.process_games team_id:#{home_team_id}"
          end
          away_team_id = g[7].to_i
          away_team = Team.find_by_nba_id(away_team_id)
          if away_team.nil?
            Rails.logger.info "Can't find away team by nba id Fetching::Games.process_games team_id:#{away_team_id}"
            next
          end
          Game.transaction do #just in case
            game = Game.find_or_create_by(nba_id: game_nba_id)
            game.home_team_id = home_team.id
            game.away_team_id = away_team.id
            game.date = game_date
            game.save
            if fetch_stat_lines
              Fetching::StatLines.process_stat_lines(game.id)
            end
          end
        end
      else
        Rails.logger "Bad response from nba Fetching::Games.process_games"
      end

    end

  end
end

