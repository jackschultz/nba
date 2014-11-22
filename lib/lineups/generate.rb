module Lineups
  module Generate

    def self.generate_lineups_ids(pcs_ids)
      pcs = PlayerCosts.find_all_by_id(pcs_ids)
      generate_lineups(pcs)
    end

    def self.generate_lineups(pcs, depth = 0)

      full_pcs = pcs.to_a
      if depth == 0
        locked_positions = []
        locked_actual = []
        locked = []
        pcs.each do |pc|
          if pc.locked == true
            locked << pc
          end
        end
        locked.each do |lock|
          lock_check = lock
          while locked_positions.include?(lock_check.position)
            lock_check = PlayerCost.where(game_id: lock.game_id, player_id: lock.player_id, position: lock_check.lower_position).first
          end
          locked_actual << lock_check
          locked_positions << lock_check.position
          pcs = pcs.where('position != ?', lock_check.position)
        end
        pcs_arr = pcs.to_a
        locked_actual.each do |lock|
          pcs_arr << lock
        end
      else
        pcs_arr = pcs.to_a
      end

      lineup = generate_lineup(pcs_arr)
=begin
      final_lineups = []
      duplicates = lineup.duplicates
      duplicates.each do |dup|
        pcs_array = pcs_arr.clone
        pcs_array.delete(dup)# if dup.id != other_dup.id
        final_lineups << generate_lineups(pcs_array, 1)
      end.empty? and begin
        final_lineups << lineup
      end
      valid_lineups = []
      final_lineups.compact.each do |fl|
        if fl.valid_players?
          valid_lineups << fl
        end
      end

      best_lineup = valid_lineups.sort_by{|l| l.expected_points}.last
      if depth == 0 && !best_lineup.nil?
        pcs_array = full_pcs.clone
        best_lineup.lineup.each do |player_cost|
          player_costs = pcs.where(player_id: player_cost.player.id)
          player_costs.each do |pc|
            pcs_array.delete(pc)
          end
        end
        secondary_lineup = generate_lineups(pcs_array, 1)
        lineups = [best_lineup, secondary_lineup]
        return lineups
      else
        return best_lineup
      end
=end
      return [lineup, lineup]
    end

    def self.filter_player_list(lineup, players)
      current_player_ids = lineup.player_ids
      players.select{|p| current_player_ids.exclude?(p.player_id)}
    end

    def self.filter_player_cost(lineup, players)
      remaining_cost = lineup.remaining_cost
      players.select{|p| p.salary < remaining_cost}
    end

    def self.filter_dominators(players)
      if players.length <= 1
        return players
      end
      top_at_salary = []
      #first thing is to get only the most expected points per salary
      players.sort_by!{|p| p.salary}
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

      non_dominated.reverse!
      non_dominated[1..-1].each_with_index do |player, index|
        prev_player = players[index]
        player.weight_slope = (player.expected_points - prev_player.expected_points) / (player.salary - prev_player.salary)
      end
      non_dominated
    end

    def self.slope_between_current(current, rest)
      rest.each_with_index do |player, index|
        #player.weight_slope = (player.expected_points - current.expected_points) / (player.salary - current.salary)
        player.current_salary_difference = player.salary - current.salary
      end
#      rest.sort_by(&:weight_slope).reverse!
      rest.sort_by(&:salary).reverse!
      return rest
    end

    def self.generate_lineup(pcs)
      ### Returns an array of possible lineups
      point_guards = pcs.map{|pc| pc.pg? && pc.expected_points != 0 ? pc : nil}.compact
      shooting_guards = pcs.map{|pc| pc.sg? && pc.expected_points != 0 ? pc : nil}.compact
      power_forwards = pcs.map{|pc| pc.pf? && pc.expected_points != 0 ? pc : nil}.compact
      small_forwards = pcs.map{|pc| pc.sf? && pc.expected_points != 0 ? pc : nil}.compact
      centers = pcs.map{|pc| pc.c? && pc.expected_points != 0 ? pc : nil}.compact
      guards = pcs.map{|pc| pc.g? && pc.expected_points != 0 ? pc : nil}.compact
      forwards = pcs.map{|pc| pc.f? && pc.expected_points != 0 ? pc : nil}.compact
      utilities = pcs.map{|pc| pc.u? && pc.expected_points != 0 ? pc : nil}.compact

=begin
      point_guards.sort_by!{|p| p.expected_points}.reverse!
      shooting_guards.sort_by!{|p| p.expected_points}.reverse!
      power_forwards.sort_by!{|p| p.expected_points}.reverse!
      small_forwards.sort_by!{|p| p.expected_points}.reverse!
      centers.sort_by!{|p| p.expected_points}.reverse!
      guards.sort_by!{|p| p.expected_points}.reverse!
      forwards.sort_by!{|p| p.expected_points}.reverse!
      utilities.sort_by!{|p| p.expected_points}.reverse!
=end

      point_guards.sort_by!{|p| p.salary}.reverse!
      shooting_guards.sort_by!{|p| p.salary}.reverse!
      power_forwards.sort_by!{|p| p.salary}.reverse!
      small_forwards.sort_by!{|p| p.salary}.reverse!
      centers.sort_by!{|p| p.salary}.reverse!
      guards.sort_by!{|p| p.salary}.reverse!
      forwards.sort_by!{|p| p.salary}.reverse!
      utilities.sort_by!{|p| p.salary}.reverse!

      pgs = filter_dominators(point_guards)
      sgs = filter_dominators(shooting_guards)
      pfs = filter_dominators(power_forwards)
      sfs = filter_dominators(small_forwards)
      cs = filter_dominators(centers)
      gs = filter_dominators(guards)
      fs = filter_dominators(forwards)
      us = filter_dominators(utilities)

      test_lineup = DraftKingsLineup.new(total_salary: 50000)
      test_lineup.point_guard = pgs.shift
      test_lineup.shooting_guard = sgs.shift
      test_lineup.power_forward = pfs.shift
      test_lineup.small_forward = sfs.shift
      test_lineup.center = cs.shift
      test_lineup.guard = gs.shift
      test_lineup.forward = fs.shift
      test_lineup.utility = us.shift

      pgs = slope_between_current(test_lineup.point_guard, pgs)
      sgs = slope_between_current(test_lineup.shooting_guard, sgs)
      sfs = slope_between_current(test_lineup.small_forward, sfs)
      pfs = slope_between_current(test_lineup.power_forward, pfs)
      cs = slope_between_current(test_lineup.center, cs)
      gs = slope_between_current(test_lineup.guard, gs)
      fs = slope_between_current(test_lineup.forward, fs)
      us = slope_between_current(test_lineup.utility, us)

      remaining_players = [pgs.first, sgs.first, pfs.first, sfs.first, cs.first, gs.first, fs.first,  us.first].compact
     #remaining_players.sort_by!{|p| p.salary}
      remaining_players.sort{|a, b| [ a.salary, a.expected_points ] <=> [ b.salary, b.expected_points ] }

      while remaining_players.length > 0

        player = remaining_players.shift

        if player.pg?
          prev = test_lineup.point_guard
          test_lineup.point_guard = player
          if !test_lineup.valid_cost?# || player.expected_points < prev.expected_points
            test_lineup.point_guard = prev
          end
          pgs.delete(player)
          pgs = slope_between_current(test_lineup.point_guard, pgs)
        elsif player.sg?
          prev = test_lineup.shooting_guard
          test_lineup.shooting_guard = player
          if !test_lineup.valid_cost?# || player.expected_points < prev.expected_points
            test_lineup.shooting_guard = prev
          end
          sgs.delete(player)
          sgs = slope_between_current(test_lineup.shooting_guard, sgs)
        elsif player.sf?
          prev = test_lineup.small_forward
          test_lineup.small_forward = player
          if !test_lineup.valid_cost?# || player.expected_points < prev.expected_points
            test_lineup.small_forward = prev
          end
          sfs.delete(player)
          sfs = slope_between_current(test_lineup.small_forward, sfs)
        elsif player.pf?
          prev = test_lineup.power_forward
          test_lineup.power_forward = player
          if !test_lineup.valid_cost?# || player.expected_points < prev.expected_points
            test_lineup.power_forward = prev
          end
          pfs.delete(player)
          pfs = slope_between_current(test_lineup.power_forward, pfs)
        elsif player.c?
          prev = test_lineup.center
          test_lineup.center = player
          if !test_lineup.valid_cost?# || player.expected_points < prev.expected_points
            test_lineup.center = prev
          end
          cs.delete(player)
          cs = slope_between_current(test_lineup.center, cs)
        elsif player.g?
          prev = test_lineup.guard
          test_lineup.guard = player
          if !test_lineup.valid_cost?# || player.expected_points < prev.expected_points
            test_lineup.guard = prev
          end
          gs.delete(player)
          gs = slope_between_current(test_lineup.guard, gs)
        elsif player.f?
          prev = test_lineup.forward
          test_lineup.forward = player
          if !test_lineup.valid_cost?# || player.expected_points < prev.expected_points
            test_lineup.forward = prev
          end
          fs.delete(player)
          fs = slope_between_current(test_lineup.forward, fs)
        elsif player.u?
          prev = test_lineup.utility
          test_lineup.utility = player
          if !test_lineup.valid_cost?# || player.expected_points < prev.expected_points
            test_lineup.utility = prev
          end
          us.delete(player)
          us = slope_between_current(test_lineup.utility, us)
        end

      pgs = slope_between_current(test_lineup.point_guard, pgs)
      sgs = slope_between_current(test_lineup.shooting_guard, sgs)
      sfs = slope_between_current(test_lineup.small_forward, sfs)
      pfs = slope_between_current(test_lineup.power_forward, pfs)
      cs = slope_between_current(test_lineup.center, cs)
      gs = slope_between_current(test_lineup.guard, gs)
      fs = slope_between_current(test_lineup.forward, fs)
      us = slope_between_current(test_lineup.utility, us)




        #remaining_players = pgs + sgs + pfs + sfs + cs + gs + fs + us
        remaining_players = [pgs.first, sgs.first, pfs.first, sfs.first, cs.first, gs.first, fs.first, us.first].compact
        if remaining_players.nil?
          break
        end
        remaining_players.sort_by!{|p| p.current_salary_difference}
        #remaining_players.sort_by!{|p| p.salary}
      end

      test_lineup

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
