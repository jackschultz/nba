module Lineups
  module Generate

    def self.filter_player_list(lineup, players)
      current_player_ids = lineup.player_ids
      players.select{|p| current_player_ids.exclude?(p.player_id)}
    end

    def self.filter_player_cost(lineup, players)
      remaining_cost = lineup.remaining_cost
      players.select{|p| p.salary < remaining_cost}
    end

    def self.filter_and_slope(players)

      top_at_salary = []
      #first thing is to get only the most expected points per salary
      players.sort_by!{|p| p.salary}.reverse
      test_player = players[0]
      players[1..-1].each_with_index do |player, index|
        if test_player.salary == player.salary
          if test_player.expected_points < player.expected_points
            test_player = player
          end
        elsif test_player.salary < player.salary
          top_at_salary << test_player
          test_player = player
        end
      end
      top_at_salary.push(test_player)

      top_at_salary.sort_by!{|p| p.expected_points}.reverse!

      non_dominated = []
      #we need to make sure that we remove the dominated ones
      test_player = top_at_salary[0]
      top_at_salary[1..-1].each_with_index do |player, index|
        if test_player.salary > player.salary
          non_dominated << test_player
          test_player = player
        end
      end
      non_dominated << test_player

      non_dominated[1..-1].each_with_index do |player, index|
        prev_player = players[index-1]
        if player.salary == prev_player.salary
        end
        player.weight_slope = (player.expected_points - prev_player.expected_points) / (player.salary - prev_player.salary)
      end
      non_dominated
    end

    def self.generate_lineups_iter(pcs)
      point_guards = pcs.map{|pc| pc.pg? && pc.expected_points != 0 ? pc : nil}.compact
      shooting_guards = pcs.map{|pc| pc.sg? && pc.expected_points != 0 ? pc : nil}.compact
      power_forwards = pcs.map{|pc| pc.pf? && pc.expected_points != 0 ? pc : nil}.compact
      small_forwards = pcs.map{|pc| pc.sf? && pc.expected_points != 0 ? pc : nil}.compact
      centers = pcs.map{|pc| pc.c? && pc.expected_points != 0 ? pc : nil}.compact
      guards = pcs.map{|pc| pc.c? && pc.expected_points != 0 ? pc : nil}.compact
      forwards = pcs.map{|pc| pc.c? && pc.expected_points != 0 ? pc : nil}.compact
      utilities = pcs.map{|pc| pc.u? && pc.expected_points != 0 ? pc : nil}.compact

      point_guards.sort_by!{|p| p.expected_points}.reverse
      shooting_guards.sort_by!{|p| p.expected_points}.reverse
      power_forwards.sort_by!{|p| p.expected_points}.reverse
      small_forwards.sort_by!{|p| p.expected_points}.reverse
      centers.sort_by!{|p| p.expected_points}.reverse
      guards.sort_by!{|p| p.expected_points}.reverse
      forwards.sort_by!{|p| p.expected_points}.reverse
      utilities.sort_by!{|p| p.expected_points}.reverse

      pgs = filter_and_slope(point_guards)
      sgs = filter_and_slope(shooting_guards)
      pfs = filter_and_slope(power_forwards)
      sfs = filter_and_slope(small_forwards)
      cs = filter_and_slope(centers)
      gs = filter_and_slope(guards)
      fs = filter_and_slope(forwards)
      us = filter_and_slope(utilities)

      test_lineup = DraftKingsLineup.new(total_salary: 50000)
      test_lineup.point_guard = pgs.shift
      test_lineup.shooting_guard = sgs.shift
      test_lineup.power_forward = pfs.shift
      test_lineup.small_forward = sfs.shift
      test_lineup.center = cs.shift
      test_lineup.guard = gs.shift
      test_lineup.forward = fs.shift
      test_lineup.utility = us.shift

      remaining_players = pgs + sgs + pfs + sfs + cs + gs + fs + us
      remaining_players.sort_by!{|p| p.weight_slope}.reverse

    end

  end
end

=begin
      lineups = []
      test_lineup = DraftKingsLineup.new(total_salary: 50000)
      point_guards.each do |pg|
        puts "PG"
        #add point guard
        test_lineup.point_guard = pg
        shooting_guards.each do |sg|
          puts "SG"
          #add shooting guard, no way these go over the limit
          test_lineup.shooting_guard = sg
          small_forwards.each do |sf|
            #add small forward, no way these go over the limit
            test_lineup.small_forward = sf
            filtered_power_forwards = power_forwards
            filtered_power_forwards.each do |pf|
              #add power forward, no way these go over the limit
              test_lineup.power_forward = pf
              centers.each do |c|
                test_lineup.center = c

                possible_guards = filter_player_list(test_lineup, guards)
                possible_guards = filter_player_cost(test_lineup, possible_guards)

                possible_guards.each do |g|
                  test_lineup.guard = g

                  possible_forwards = filter_player_list(test_lineup, forwards)
                  possible_forwards = filter_player_cost(test_lineup, possible_forwards)

                  possible_forwards.each do |f|
                    test_lineup.forward = f

                    possible_utilities = filter_player_list(test_lineup, utilities)
                    possible_utilities = filter_player_cost(test_lineup, possible_utilities)
                    u = possible_utilities.sort_by{|p| p.expected_points}.first

                    test_lineup.utility = u
                    lineups << test_lineup

                  end
                end
              end
            end
          end
        end
      end
      lineups




=end
