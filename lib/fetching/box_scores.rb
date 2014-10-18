require "faraday"
require "faraday_middleware"
require "net/http"
require "nokogiri"
require "json"

module Fetching
  module BoxScore

    def self.fetch_player_information(purl, player)
      response = conn.get(purl)
      if response.success?
        doc = Nokogiri::HTML(response.body)
        ts = doc.css('#tab-stats')
        stat_url = ts.first.attributes['href'].value
        nba_id = stat_url.split('=').last.to_i
        team_name = doc.css('.player-team').first.children.text
        team_mascot = team_name.split(' ').last
        team = find_team_for_player(team_mascot)
        player.nba_id = nba_id
        player.team = team
        player.save
        puts "#{player.full_name} plays for #{player.team.full_name}"
      else
        puts "Couldn't get response for #{player.inspect}"
      end
    end

    def self.process_box_score(game_id, date = nil)
      url = 'http://stats.nba.com/stats/boxscore/'
      params = {}
      params['GameID'] = game_id
      params['StartRange'] = 0
      params['EndRange'] = 0
      params['StartPeriod'] = 0
      params['EndPeriod'] = 0
      params['RangeType'] = 0
      resp = fetch_from_nba(url, params)
      if resp
        result = JSON.parse(resp)['resultSet']
      else
        raise "Bad response from nba Fetching::Games.process_games"
      end

    end

  end
end

