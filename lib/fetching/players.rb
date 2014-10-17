require "faraday"
require "faraday_middleware"
require "net/http"
require "nokogiri"

module Fetching
  module Players

    def self.build_conn
      endpoint = 'http://stats.nba.com'
      connection = Faraday.new(endpoint) do |co|
        co.request :url_encoded
        co.adapter  Faraday.default_adapter
      end
      connection
    end

    def self.conn
      @conn ||=build_conn
    end

    def self.fetch_from_nba
      url = 'http://stats.nba.com/frags/stats-site-page-players-directory-active.html'
      response = conn.get(url)
      if response.success?
        response.body
      else
        false
      end
    end

    def self.fetch_player_information(purl, player)
      response = conn.get(purl)
      if response.success?
        doc = Nokogiri::HTML(response.body)
        ts = doc.css('#tab-stats')
        stat_url = ts.first.attributes['href'].value
        nba_id = stat_url.split('=').last.to_i
        team_name = doc.css('.player-team').first.children.text
        team_mascot = team_name.split(' ').last
        team = Team.find_by_mascot(team_mascot)
        if team.nil?
          puts "Couldn't find team #{team_name}"
          return
        end
        player.nba_id = nba_id
        player.team = team
        player.save
        puts "#{player.full_name} plays for #{team_name}"
      else
        false
      end
    end

    def self.process_players
      resp = fetch_from_nba
      if resp
        doc = Nokogiri::HTML(resp)
        doc.css('.playerlink').each do |pdiv|
          purl = pdiv.attributes['href'].value
          underscored_name = purl.split('/').last
          first_name, last_name = pdiv.children.text.split(',').map(&:strip)
          player = Player.find_by(underscored_name: underscored_name)
          if !player.nil?
            player.first_name = first_name
            player.last_name = last_name
            player.save
          else
            player = Player.create(first_name: first_name, last_name: last_name)
            fetch_player_information(purl, player)
          end
        end
      end
    end

  end
end
#'stats.nba.com/leagueTeamGeneral.html'

=begin
def gather_players():
  resp = requests.get(url=url)
  if resp.status_code == 200:
    data = BeautifulSoup(resp.text)
    player_data = data.find_all(class_="playerlink")
    for player in player_data:
      player_url = player['href']
      last_slash = player_url.rfind('/')
      underscored_name = player_url[last_slash+1:]
      try:
        player = Player.objects.get(underscored_name=underscored_name)
        print "Found " + underscored_name + " with id " + str(player.pid)
      except Player.DoesNotExist:
        print "Didn't find " + underscored_name + " attempting to find id."
        player_page = requests.get(url=player_url)
        player_soup = BeautifulSoup(player_page.text)
        player_stats_profile_link = player_soup.find(id='tab-stats')
        player_stat_url = player_stats_profile_link['href']
        player_id_string = 'PlayerID='
        player_id_start = player_stat_url.find(player_id_string)
        player_id = int(player_stat_url[player_id_start+len(player_id_string):])
        print "Player " + underscored_name + " has id " + str(player_id)
        try:
          #don't know why this would be the case though
          player = Player.objects.get(pid=player_id)
          player['underscored_name'] = underscored_name
          player.save()
        except Player.DoesNotExist:
          player = Player(pid=player_id, underscored_name=underscored_name)
          player.save()
=end
