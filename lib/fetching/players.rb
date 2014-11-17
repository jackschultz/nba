require "faraday"
require "faraday_middleware"
require "net/http"
require "nokogiri"

module Fetching
  class Players < NbaApi

    def self.find_team_for_player(team_mascot)
      team = Team.find_by_mascot(team_mascot)
      if team.nil?
        team = Team.find_by_alternate_name(team_mascot)
      end
      team
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
        team = find_team_for_player(team_mascot)
        player.nba_id = nba_id
        player.team = team
        player.save
        puts "#{player.full_name} plays for #{player.team.full_name}"
      else
        puts "Couldn't get response for #{player.inspect}"
      end
    end

    def self.process_players
      url = 'http://stats.nba.com/frags/stats-site-page-players-directory-active.html'
      resp = fetch_from_nba(url)
      if resp
        doc = Nokogiri::HTML(resp)
        doc.css('.playerlink').each do |pdiv|
          purl = pdiv.attributes['href'].value
          underscored_name = purl.split('/').last
          last_name, first_name = pdiv.children.text.split(',').map(&:strip)
          player = Player.find_by(underscored_name: underscored_name)
          if !player.nil? && !player.team.nil?
            player.first_name = first_name
            player.last_name = last_name
            player.save
            puts "Found: #{player.full_name} (id #{player.id}) plays for #{player.team.full_name}"
          else
            player = Player.create(first_name: first_name, last_name: last_name, underscored_name: underscored_name)
            fetch_player_information(purl, player)
          end
        end
      end
    end

    def self.process_starters
      game_ids = Game.today.map(&:id)
      PlayerCost.from_games(game_ids).each do |pc|
        pc.healthy = true
        pc.starting = false
        pc.save
      end
      url = "http://www.rotowire.com/basketball/nba_lineups.htm"
      response = conn.get(url)
      if response.success?
        doc = Nokogiri::HTML(response.body)
        doc.css('.dlineups-teamsnba').each do |game| #.first.next_element.css('.dlineups-vplayer').count
          game.next_element.css('.dlineups-vplayer').each do |pnode|
            full_name = pnode.children[3].children.text
            player = find_player_by_full_name(full_name)
            if player.nil?
              next
            end
            pcs = player.player_costs.from_games(game_ids)
            if pcs.empty?
              Rails.logger.info "Cannot find player cost for player today with name: #{full_name}"
              next
            end
            pcs.each do |pc|
              pc.starting = true
              pc.save
            end
          end
        end
        doc.css('.dlineups-nbainactiveblock').each do |block|
          block.css('.dlineups-vplayer').each do |pnode|
            full_name = pnode.children[3].children.text
            player = find_player_by_full_name(full_name)
            if player.nil?
              next
            end
            pcs = player.player_costs.from_games(game_ids)
            if pcs.empty?
              Rails.logger.info "Cannot find player cost for player today with name: #{full_name}"
              next
            end
            pcs.each do |pc|
              pc.healthy = false
              pc.save
            end
          end
        end
      end
    end

    def self.find_player_by_full_name(full_name)
      fn_split = full_name.split(' ')
      first_name = fn_split[0]
      last_name = fn_split[1..-1].join(' ')
      player = Player.find_by_first_name_and_last_name(first_name, last_name)
      if player.nil?
        Rails.logger.info "Cannot find player with name: #{full_name}"
        poss_player = Player.where(last_name: last_name)
        player = poss_player.first
      end
      player
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
