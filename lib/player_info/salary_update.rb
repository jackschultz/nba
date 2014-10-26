require 'CSV'

module PlayerInfo
  class SalaryUpdate

    def self.update_draft_kings(date=nil)
      date ||= DateTime.now
      date_string = date.strftime('%F')
      site = Site.find_by_name("Draft Kings")
      filename = "lib/player_info/dk_salaries-#{date_string}.csv"
      CSV.foreach(filename, {headers: true}) do |row|
        position = row[0]
        full_name = row[1].split(' ')
        first_name = full_name[0]
        last_name = full_name[1..-1].join(' ')
        player = Player.find_by_first_name_and_last_name(first_name, last_name)
        if player.nil?
          Rails.logger.info "Cannot find player with name: #{row[1]}"
          next
        end
        game = Game.where(date: date).where('home_team_id=? OR away_team_id=?', player.team_id, player.team_id).first
        if game.nil?
          Rails.logger.info "Cannot find game for date #{date} and player #{player.inspect}"
          next
        end
        salary = row[2]
        sinfo = site.player_costs.where(player_id: player.id, game_id: game.id).first_or_create
        sinfo.position = position
        sinfo.salary = salary
        sinfo.save
      end
    end

    def self.update_fan_duel
      site = Site.find_by_name("Fan Duel")
      CSV.foreach("DKSalaries.csv", {headers: true}) do |row|

      end
    end

    def self.update_draft_day
      site = Site.find_by_name("Draft Day")
      CSV.foreach("lib/player_info/draft_day_salaries.csv", {headers: true}) do |row|
        position = row[0]
        full_name = row[1].split(' ')
        first_name = full_name[0]
        last_name = full_name[1..-1].join(' ')
        player = Player.find_by_first_name_and_last_name(first_name, last_name)
        if player.nil?
          Rails.logger.info "Cannot find player with name: #{row[1]}"
          next
        end
        next
        salary = row[4]
        sinfo = site.site_player_infos.where(player_id: player.id).first_or_create
        sinfo.position = position
        sinfo.salary = salary
        sinfo.save
      end
    end

  end
end
