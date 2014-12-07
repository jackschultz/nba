games = Game.on_date(Date.today)
pcs = PlayerCost.from_games(games.map(&:id)).positive.primary.healthy
pcs.each {|pc| puts "#{pc.id},#{pc.player.team_id}, #{pc.position}, #{pc.salary}, #{pc.expected_points}" }
