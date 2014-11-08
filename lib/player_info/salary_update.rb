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
        game = Game.where(date: date_string).where('home_team_id=? OR away_team_id=?', player.team_id, player.team_id).first
        if game.nil?
          Rails.logger.info "Cannot find game for date #{date} and player #{player.inspect}"
          next
        end
        salary = row[2]
        sinfo = site.player_costs.where(player_id: player.id, game_id: game.id).first_or_create
        sinfo.position = position
        sinfo.salary = salary
        sinfo.save
        sinfo.expected_points = row[-1].to_f #sinfo.player.avg_draft_kings
        sinfo.save
        generate_other_player_costs(sinfo)
      end
    end

    def self.generate_other_player_costs(pc)
      pcs_by_position = pc.site.player_costs.where(player_id: pc.player.id, game_id: pc.game.id).map(&:position)
      if pc.pg? || pc.sg? && !pcs_by_position.include?("G")
        gpc = pc.dup
        gpc.position = "G"
        gpc.save
      end
      if pc.sf? || pc.pf? && !pcs_by_position.include?("F")
        gpc = pc.dup
        gpc.position = "F"
        gpc.save
      end
      if !pcs_by_position.include?("U")
        gpc = pc.dup
        gpc.position = "U"
        gpc.save
      end

    end

  end
end
