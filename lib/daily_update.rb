module DailyUpdate

  def self.update(date = Date.today)
    Fetching::Games.process_games_range(date, date, true, false)
    yesterday = date - 1.day
    Fetching::Games.process_games_range(yesterday, yesterday, true, true)
    PlayerInfo::SalaryUpdate.update_draft_kings(date)
  #  Fetching::Players.process_starters
=begin
    game_ids = Game.today.map(&:id)
    pcs = PlayerCost.from_games(game_ids)
    Lineups::Generate.generate_lineups_iter(pcs)
=end

  end

end
