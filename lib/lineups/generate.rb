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

      lineup = generate_lineup_lm(pcs_arr)
#      lineup = generate_lineup_dyn(pcs_arr)
#      lineup = generate_lineup_brute(pcs_arr)

      [lineup, lineup]
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
      non_dominated << test_player ##add cheapest

      non_dominated.reverse!
      return non_dominated
      non_lp_dominated = non_dominated
      non_lp_dominated = []

      non_lp_dominated << non_dominated.first
      if non_dominated.length >= 3
        low_player = non_dominated.first
        high_player = non_dominated[2]
        non_dominated[1..-2].each_with_index do |player, index|
          det = (player.salary - low_player.salary)*(high_player.expected_points - low_player.expected_points) - (player.expected_points - low_player.expected_points)*(high_player.salary - low_player.salary)
          if det < 0
            non_lp_dominated << player
            low_player = player
          else
          end
          high_player = non_dominated[index+3]
        end
      else
        non_lp_dominated = non_dominated
      end
      non_lp_dominated << non_dominated.last

      non_lp_dominated[1..-1].each_with_index do |player, index|
        prev_player = players[index]
        player.weight_slope = (player.expected_points - prev_player.expected_points) / (player.salary - prev_player.salary)
      end

      non_lp_dominated
    end

    def self.filter_lp_dominators(players)
      non_lp_dominated = []

      non_lp_dominated << players.first
      if players.length >= 3
        low_player = players.first
        high_player = players[2]
        players[1..-2].each_with_index do |player, index|
          det = (player.salary - low_player.salary)*(high_player.expected_points - low_player.expected_points) - (player.expected_points - low_player.expected_points)*(high_player.salary - low_player.salary)
          if det < 0
            non_lp_dominated << player
            low_player = player
          else
          end
          high_player = players[index+3]
        end
      else
        non_lp_dominated = non_dominated
      end
      non_lp_dominated << players.last

      non_lp_dominated[1..-1].each_with_index do |player, index|
        prev_player = players[index]
        player.weight_slope = (player.expected_points - prev_player.expected_points) / (player.salary - prev_player.salary)
      end

      non_lp_dominated

    end

    def self.salary_between_current(current, rest)
      rest.each_with_index do |player, index|
        #player.weight_slope = (player.expected_points - current.expected_points) / (player.salary - current.salary)
        player.current_salary_difference = player.salary - current.salary
      end
#      rest.sort_by(&:weight_slope).reverse!
      rest.sort_by(&:salary).reverse!
      return rest
    end

    def self.slope_between_prev(pcs)
      pcs[1..-1].each_with_index do |pc, i|
        pc.weight_slope = (pc.expected_points - pcs[i].expected_points) / (pc.salary - pcs[i].salary)
      end
      pcs
    end

    def self.slope_between_current(current, rest)
      rest.each_with_index do |player, index|
        player.current_salary_difference = player.salary - current.salary
      end
      rest.sort_by(&:salary).reverse!
      return rest
    end

    def self.generate_lineup_brute(pcs)

      ### Returns an array of possible lineups
      point_guards = pcs.map{|pc| pc.pg? && pc.expected_points != 0 ? pc : nil}.compact
      shooting_guards = pcs.map{|pc| pc.sg? && pc.expected_points != 0 ? pc : nil}.compact
      power_forwards = pcs.map{|pc| pc.pf? && pc.expected_points != 0 ? pc : nil}.compact
      small_forwards = pcs.map{|pc| pc.sf? && pc.expected_points != 0 ? pc : nil}.compact
      centers = pcs.map{|pc| pc.c? && pc.expected_points != 0 ? pc : nil}.compact
      guards = pcs.map{|pc| pc.g? && pc.expected_points != 0 ? pc : nil}.compact
      forwards = pcs.map{|pc| pc.f? && pc.expected_points != 0 ? pc : nil}.compact
      utilities = pcs.map{|pc| pc.u? && pc.expected_points != 0 ? pc : nil}.compact

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

      lineups = []
      test_lineup = DraftKingsLineup.new(total_salary: 50000)
      pgs.each do |pg|
        puts "PG"
        #add point guard
        test_lineup.point_guard = pg
        sgs.each do |sg|
          puts "SG"
          #add shooting guard, no way these go over the limit
          test_lineup.shooting_guard = sg
          sfs.each do |sf|
            #add small forward, no way these go over the limit
            test_lineup.small_forward = sf
            pfs.each do |pf|
              #add power forward, no way these go over the limit
              test_lineup.power_forward = pf
              cs.each do |c|
                test_lineup.center = c
                possible_guards = filter_player_list(test_lineup, gs)
                possible_guards.each do |g|
                  test_lineup.guard = g
                  possible_forwards = filter_player_list(test_lineup, fs)
                  possible_forwards.each do |f|
                    test_lineup.forward = f
                    u = us.sort_by{|p| p.expected_points}.first
                    test_lineup.utility = u
                    lineups << test_lineup.clone if test_lineup.valid?
                  end
                end
              end
            end
          end
        end
      end

      lineups.sort! { |a,b| b.expected_points <=> a.expected_points }.first

    end

    def self.generate_lineup_lm(pcs)

      ### Returns an array of possible lineups
      point_guards = pcs.map{|pc| pc.pg? && pc.expected_points != 0 ? pc : nil}.compact
      shooting_guards = pcs.map{|pc| pc.sg? && pc.expected_points != 0 ? pc : nil}.compact
      power_forwards = pcs.map{|pc| pc.pf? && pc.expected_points != 0 ? pc : nil}.compact
      small_forwards = pcs.map{|pc| pc.sf? && pc.expected_points != 0 ? pc : nil}.compact
      centers = pcs.map{|pc| pc.c? && pc.expected_points != 0 ? pc : nil}.compact
      guards = pcs.map{|pc| pc.g? && pc.expected_points != 0 ? pc : nil}.compact
      forwards = pcs.map{|pc| pc.f? && pc.expected_points != 0 ? pc : nil}.compact
      utilities = pcs.map{|pc| pc.u? && pc.expected_points != 0 ? pc : nil}.compact

      point_guards.sort_by!{|p| p.salary}.reverse!
      shooting_guards.sort_by!{|p| p.salary}.reverse!
      power_forwards.sort_by!{|p| p.salary}.reverse!
      small_forwards.sort_by!{|p| p.salary}.reverse!
      centers.sort_by!{|p| p.salary}.reverse!
      guards.sort_by!{|p| p.salary}.reverse!
      forwards.sort_by!{|p| p.salary}.reverse!
      utilities.sort_by!{|p| p.salary}.reverse!

      pgs_dom = filter_dominators(point_guards)
      sgs_dom = filter_dominators(shooting_guards)
      pfs_dom = filter_dominators(power_forwards)
      sfs_dom = filter_dominators(small_forwards)
      cs_dom = filter_dominators(centers)
      gs_dom = filter_dominators(guards)
      fs_dom = filter_dominators(forwards)
      us_dom = filter_dominators(utilities)

      pgs_lp = filter_lp_dominators(pgs_dom)
      sgs_lp = filter_lp_dominators(sgs_dom)
      pfs_lp = filter_lp_dominators(pfs_dom)
      sfs_lp = filter_lp_dominators(sfs_dom)
      cs_lp = filter_lp_dominators(cs_dom)
      gs_lp = filter_lp_dominators(gs_dom)
      fs_lp = filter_lp_dominators(fs_dom)
      us_lp = filter_lp_dominators(us_dom)

      pgs = slope_between_prev(pgs_lp)
      sgs = slope_between_prev(sgs_lp)
      sfs = slope_between_prev(sfs_lp)
      pfs = slope_between_prev(pfs_lp)
      cs = slope_between_prev(cs_lp)
      gs = slope_between_prev(gs_lp)
      fs = slope_between_prev(fs_lp)
      us = slope_between_prev(us_lp)

      current_best_lineup = DraftKingsLineup.new(total_salary: 50000)
      current_best_lineup.add_player(pgs_lp.shift)
      current_best_lineup.add_player(sgs_lp.shift)
      current_best_lineup.add_player(sfs_lp.shift)
      current_best_lineup.add_player(pfs_lp.shift)
      current_best_lineup.add_player(cs_lp.shift)
      g = gs_lp.shift
      while current_best_lineup.player_in_lineup?(g)
        g = gs_lp.shift
      end
      current_best_lineup.add_player(g)
      f = fs_lp.shift
      while current_best_lineup.player_in_lineup?(f)
        f = fs_lp.shift
      end
      current_best_lineup.add_player(f)
      u = us_lp.shift
      while current_best_lineup.player_in_lineup?(u)
        u = us_lp.shift
      end
      current_best_lineup.add_player(u)

      remaining_players = pgs_lp + sgs_lp + pfs_lp + sfs_lp + cs_lp + gs_lp + fs_lp + us_lp
      #non decreasing order
      remaining_players.sort_by!{|p| p.weight_slope}.reverse!

      best_at_salary = {}

      best_valid_cost = current_best_lineup.current_cost
      while remaining_players.length > 0

        best_valid_cost = current_best_lineup.current_cost

        player = remaining_players.shift
        old_player = current_best_lineup.add_player(player)

        best_at_salary[current_best_lineup.current_cost] = current_best_lineup.clone
        if current_best_lineup.current_cost > 50000
        #  new_player = current_best_lineup.add_player(old_player)
          break
        end

      end

      best_lineup = best_at_salary[best_at_salary.keys[-1]]
      c = 50000
      l = (player.expected_points - old_player.expected_points) / (player.salary - old_player.salary)
      cap_P = best_lineup.expected_points
      cap_W = best_lineup.current_cost
      z = cap_P + (c - cap_W)*l

      best_p = best_lineup.point_guard
      possible_pgs = []
      pgs_dom.each do |p|
        u = (cap_P - best_p.expected_points + p.expected_points) + l*(c - cap_W + best_p.salary - p.salary)
        if u > z || best_p.player_id == p.player_id
          possible_pgs << p
        end
      end
      best_p = best_lineup.shooting_guard
      possible_sgs = []
      sgs_dom.each do |p|
        u = (cap_P - best_p.expected_points + p.expected_points) + l*(c - cap_W + best_p.salary - p.salary)
        if u > z || best_p.player_id == p.player_id
          possible_sgs << p
        end
      end
      best_p = best_lineup.small_forward
      possible_sfs = []
      sfs_dom.each do |p|
        u = (cap_P - best_p.expected_points + p.expected_points) + l*(c - cap_W + best_p.salary - p.salary)
        if u > z || best_p.player_id == p.player_id
          possible_sfs << p
        end
      end
      best_p = best_lineup.power_forward
      possible_pfs = []
      pfs_dom.each do |p|
        u = (cap_P - best_p.expected_points + p.expected_points) + l*(c - cap_W + best_p.salary - p.salary)
        if u > z || best_p.player_id == p.player_id
          possible_pfs << p
        end
      end
      best_p = best_lineup.center
      possible_cs = []
      cs_dom.each do |p|
        u = (cap_P - best_p.expected_points + p.expected_points) + l*(c - cap_W + best_p.salary - p.salary)
        if u > z || best_p.player_id == p.player_id
          possible_cs << p
        end
      end
      best_p = best_lineup.guard
      possible_gs = []
      gs_dom.each do |p|
        u = (cap_P - best_p.expected_points + p.expected_points) + l*(c - cap_W + best_p.salary - p.salary)
        if u > z || best_p.player_id == p.player_id
          possible_gs << p
        end
      end
      best_p = best_lineup.forward
      possible_fs = []
      fs_dom.each do |p|
        u = (cap_P - best_p.expected_points + p.expected_points) + l*(c - cap_W + best_p.salary - p.salary)
        if u > z || best_p.player_id == p.player_id
          possible_fs << p
        end
      end
      best_p = best_lineup.utility
      possible_us = []
      us_dom.each do |p|
        u = (cap_P - best_p.expected_points + p.expected_points) + l*(c - cap_W + best_p.salary - p.salary)
        if u > z || best_p.player_id == p.player_id
          possible_us << p
        end
      end

      binding.pry

      lineups = []
      test_lineup = DraftKingsLineup.new(total_salary: 50000)
      possible_pgs.each do |pg|
        puts "PG"
        #add point guard
        test_lineup.point_guard = pg
        possible_sgs.each do |sg|
          puts "SG"
          #add shooting guard, no way these go over the limit
          test_lineup.shooting_guard = sg
          possible_sfs.each do |sf|
            puts "SF"
            #add small forward, no way these go over the limit
            test_lineup.small_forward = sf
            possible_pfs.each do |pf|
              puts "PF"
              #add power forward, no way these go over the limit
              test_lineup.power_forward = pf
              possible_cs.each do |c|
                puts "C"
                test_lineup.center = c
               # possible_guards = filter_player_list(test_lineup, gs)
                possible_gs.each do |g|
                  puts "G"
                  test_lineup.guard = g
                #  possible_forwards = filter_player_list(test_lineup, fs)
                  possible_fs.each do |f|
                    puts "F"
                    test_lineup.forward = f
                    possible_us.each do |u|
                      puts "U"
                   # u = us.sort_by{|p| p.expected_points}.first
                      test_lineup.utility = u
                      lineups << test_lineup.clone if test_lineup.valid?
                    end
                  end
                end
              end
            end
          end
        end
      end

      return lineups.sort! { |a,b| b.expected_points <=> a.expected_points }.first

      return best_lineup

      #second part of the alg.
      test_cost = best_valid_cost
      final_cost = 50000

      while test_cost <= final_cost

        #salary difference is the difference between the target cost for this loop
        #and the cost of the lineup as it is

        possible_subs = []

        possible_costs = best_at_salary.keys.select{|s| s < test_cost }

        possible_costs.each do |salary_cost|

          lineup = best_at_salary[salary_cost]

          if !lineup.nil?

            pgs.each do |pg|
              if (salary_cost - lineup.point_guard.salary + pg.salary) == test_cost
                expected_points_difference = lineup.expected_points + (pg.expected_points - lineup.point_guard.expected_points)
                pg.expected_points_difference = expected_points_difference
                pg.prev_lineup_cost = lineup.current_cost
                possible_subs << pg.dup
              end
            end
            sgs.each do |sg|
              if (salary_cost - lineup.shooting_guard.salary + sg.salary) == test_cost
                sg.expected_points_difference = lineup.expected_points + (sg.expected_points - lineup.shooting_guard.expected_points)
                sg.prev_lineup_cost = lineup.current_cost
                possible_subs << sg.dup
              end
            end
            sfs.each do |sf|
              if (salary_cost - lineup.small_forward.salary + sf.salary) == test_cost
                sf.expected_points_difference = lineup.expected_points + (sf.expected_points - lineup.small_forward.expected_points)
                sf.prev_lineup_cost = lineup.current_cost
                possible_subs << sf.dup
              end
            end
            pfs.each do |pf|
              if (salary_cost - lineup.power_forward.salary + pf.salary) == test_cost
                pf.expected_points_difference = lineup.expected_points + (pf.expected_points - lineup.power_forward.expected_points)
                pf.prev_lineup_cost = lineup.current_cost
                possible_subs << pf.dup
              end
            end
            cs.each do |c|
              if (salary_cost - lineup.center.salary + c.salary) == test_cost
                c.expected_points_difference = lineup.expected_points + (c.expected_points - lineup.center.expected_points)
                c.prev_lineup_cost = lineup.current_cost
                possible_subs << c.dup
              end
            end
            gs.each do |g|
              if (salary_cost - lineup.guard.salary + g.salary) == test_cost
                g.expected_points_difference = lineup.expected_points + (g.expected_points - lineup.guard.expected_points)
                g.prev_lineup_cost = lineup.current_cost
                possible_subs << g.dup
              end
            end
            fs.each do |f|
              if (salary_cost - lineup.forward.salary + f.salary) == test_cost
                f.expected_points_difference = lineup.expected_points + (f.expected_points - lineup.forward.expected_points)
                f.prev_lineup_cost = lineup.current_cost
                possible_subs << f.dup
              end
            end
            us.each do |u|
              if (salary_cost - lineup.utility.salary + u.salary) == test_cost
                u.expected_points_difference = lineup.expected_points + (u.expected_points - lineup.utility.expected_points)
                u.prev_lineup_cost = lineup.current_cost
                possible_subs << u.dup
              end
            end
          end

        end

        possible_subs.sort_by!(&:expected_points_difference).reverse!.uniq!

        cache_lineup = current_best_lineup.clone


        if possible_subs.any?

          valid_player = false
          while possible_subs.length > 0
            player = possible_subs.shift
            test_lineup = best_at_salary[player.prev_lineup_cost]
            lineup_player_ids = test_lineup.player_ids
            if !lineup_player_ids.include?(player.player_id)
              if cache_lineup.expected_points < player.expected_points_difference
                valid_player = true
                break
              end
            end
          end

          if valid_player
            cache_lineup = test_lineup.clone
            cache_lineup.add_player(player.dup)
          end
        else

        end

        best_at_salary[test_cost] = cache_lineup.clone
        current_best_lineup = cache_lineup.clone

        puts "#{test_cost}, #{current_best_lineup.current_cost}, #{current_best_lineup.expected_points}"

        test_cost += 100

      end

      current_best_lineup.clone




























    end

    def self.generate_lineup_dyn2(pcs)

      ### Returns an array of possible lineups
      point_guards = pcs.map{|pc| pc.pg? && pc.expected_points != 0 ? pc : nil}.compact
      shooting_guards = pcs.map{|pc| pc.sg? && pc.expected_points != 0 ? pc : nil}.compact
      power_forwards = pcs.map{|pc| pc.pf? && pc.expected_points != 0 ? pc : nil}.compact
      small_forwards = pcs.map{|pc| pc.sf? && pc.expected_points != 0 ? pc : nil}.compact
      centers = pcs.map{|pc| pc.c? && pc.expected_points != 0 ? pc : nil}.compact
      guards = pcs.map{|pc| pc.g? && pc.expected_points != 0 ? pc : nil}.compact
      forwards = pcs.map{|pc| pc.f? && pc.expected_points != 0 ? pc : nil}.compact
      utilities = pcs.map{|pc| pc.u? && pc.expected_points != 0 ? pc : nil}.compact

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

      current_best_lineup = DraftKingsLineup.new(total_salary: 50000)
      current_best_lineup.point_guard = pgs.shift
      current_best_lineup.shooting_guard = sgs.shift
      current_best_lineup.power_forward = pfs.shift
      current_best_lineup.small_forward = sfs.shift
      current_best_lineup.center = cs.shift
      current_best_lineup.guard = gs.shift
      current_best_lineup.forward = fs.shift
      current_best_lineup.utility = us.shift

      remaining_players = pgs + sgs + pfs + sfs + cs + gs + fs + us

      test_cost = current_best_lineup.current_cost
      final_cost = 50000
      max_player_cost = us.last.salary

      test_lineups = {}

      while test_cost <= final_cost

        puts "#{test_cost}: #{current_best_lineup.expected_points}"
        #salary difference is the difference between the target cost for this loop
        #and the cost of the lineup as it is

        possible_subs = []

        min_test_lineup_cost = current_best_lineup.current_cost - max_player_cost
        possible_costs = min_test_lineup_cost.floor.upto(test_cost)

        possible_costs.each do |salary_cost|

          lineup = test_lineups[salary_cost]

          if !lineup.nil?
            pgs.each do |pg|
              if (salary_cost - lineup.point_guard.salary + pg.salary) == test_cost
                expected_points_difference = pg.expected_points - lineup.point_guard.expected_points
                pg.expected_points_difference = expected_points_difference
                pg.prev_lineup_cost = lineup.current_cost
                possible_subs << pg.dup
              end
            end
            sgs.each do |sg|
              if (salary_cost - lineup.shooting_guard.salary + sg.salary) == test_cost
                sg.expected_points_difference = sg.expected_points - lineup.shooting_guard.expected_points
                sg.prev_lineup_cost = lineup.current_cost
                possible_subs << sg.dup
              end
            end
            sfs.each do |sf|
              if (salary_cost - lineup.small_forward.salary + sf.salary) == test_cost
                sf.expected_points_difference = sf.expected_points - lineup.small_forward.expected_points
                sf.prev_lineup_cost = lineup.current_cost
                possible_subs << sf.dup
              end
            end
            pfs.each do |pf|
              if (salary_cost - lineup.power_forward.salary + pf.salary) == test_cost
                pf.expected_points_difference = pf.expected_points - lineup.power_forward.expected_points
                pf.prev_lineup_cost = lineup.current_cost
                possible_subs << pf.dup
              end
            end
            cs.each do |c|
              if (salary_cost - lineup.center.salary + c.salary) == test_cost
                c.expected_points_difference = c.expected_points - lineup.center.expected_points
                c.prev_lineup_cost = lineup.current_cost
                possible_subs << c.dup
              end
            end
            gs.each do |g|
              if (salary_cost - lineup.guard.salary + g.salary) == test_cost
                g.expected_points_difference = g.expected_points - lineup.guard.expected_points
                g.prev_lineup_cost = lineup.current_cost
                possible_subs << g.dup
              end
            end
            fs.each do |f|
              if (salary_cost - lineup.forward.salary + f.salary) == test_cost
                f.expected_points_difference = f.expected_points - lineup.forward.expected_points
                f.prev_lineup_cost = lineup.current_cost
                possible_subs << f.dup
              end
            end
            us.each do |u|
              if (salary_cost - lineup.utility.salary + u.salary) == test_cost
                u.expected_points_difference = u.expected_points - lineup.utility.expected_points
                u.prev_lineup_cost = lineup.current_cost
                possible_subs << u.dup
              end
            end
          end

        end

        possible_subs.sort_by!(&:expected_points_difference).reverse!.uniq!

        cache_lineup = current_best_lineup.clone

        puts "#{test_cost}, #{current_best_lineup.current_cost}, #{current_best_lineup.expected_points}: #{current_best_lineup.lineup.map(&:player_id)}"

        if possible_subs.any?

          lineup_player_ids = current_best_lineup.lineup.map(&:player_id)
          valid_player = false
          while possible_subs.length > 0
            player = possible_subs.shift
            if !lineup_player_ids.include?(player.player_id)
              test_lineup = test_lineups[player.prev_lineup_cost]
              if cache_lineup.expected_points < (test_lineup.expected_points + player.expected_points_difference)
                valid_player = true
                break
              end
            end
          end

          if valid_player
            cache_lineup = test_lineup.clone
            cache_lineup.add_player(player.dup)
          end
        else

        end

        test_lineups[test_cost] = cache_lineup.clone
        current_best_lineup = cache_lineup.clone

        test_cost += 100

      end

      #current_best_lineup.clone
      test_lineups[final_cost]























    end


    def self.generate_lineup_dyn(pcs)

      ### Returns an array of possible lineups
      point_guards = pcs.map{|pc| pc.pg? && pc.expected_points != 0 ? pc : nil}.compact
      shooting_guards = pcs.map{|pc| pc.sg? && pc.expected_points != 0 ? pc : nil}.compact
      power_forwards = pcs.map{|pc| pc.pf? && pc.expected_points != 0 ? pc : nil}.compact
      small_forwards = pcs.map{|pc| pc.sf? && pc.expected_points != 0 ? pc : nil}.compact
      centers = pcs.map{|pc| pc.c? && pc.expected_points != 0 ? pc : nil}.compact
      guards = pcs.map{|pc| pc.g? && pc.expected_points != 0 ? pc : nil}.compact
      forwards = pcs.map{|pc| pc.f? && pc.expected_points != 0 ? pc : nil}.compact
      utilities = pcs.map{|pc| pc.u? && pc.expected_points != 0 ? pc : nil}.compact

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

      current_best_lineup = DraftKingsLineup.new(total_salary: 50000)
      current_best_lineup.add_player(pgs.shift)
      current_best_lineup.add_player(sgs.shift)
      current_best_lineup.add_player(sfs.shift)
      current_best_lineup.add_player(pfs.shift)
      current_best_lineup.add_player(cs.shift)
      g = gs.shift
      while current_best_lineup.player_in_lineup?(g)
        g = gs.shift
      end
      current_best_lineup.add_player(g)
      f = fs.shift
      while current_best_lineup.player_in_lineup?(f)
        f = fs.shift
      end
      current_best_lineup.add_player(f)
      u = us.shift
      while current_best_lineup.player_in_lineup?(u)
        u = us.shift
      end
      current_best_lineup.add_player(u)

      remaining_players = pgs + sgs + pfs + sfs + cs + gs + fs + us

      test_salary = current_best_lineup.current_cost
      end_salary = 50000

      top_at_salary = {}
      top_at_salary[test_salary] = current_best_lineup.clone

      while test_salary <= end_salary

        puts "#{test_salary}, #{top_at_salary[test_salary].expected_points if top_at_salary[test_salary]}"

        if top_at_salary[test_salary]
          remaining_players.each do |player|
            test_lineup = top_at_salary[test_salary].clone
            old_player = test_lineup.add_player(player)
            if !old_player.nil? && test_lineup.valid_cost?
              #now check if this lineup has been accounted for
              new_lineup_cost = test_lineup.current_cost
              if top_at_salary[new_lineup_cost].nil? || top_at_salary[new_lineup_cost].expected_points < test_lineup.expected_points
                top_at_salary[new_lineup_cost] = test_lineup.clone
                test_lineup.add_player(old_player) #add the old player back
              end
            end
          end
        end

        test_salary += 100

      end
      return top_at_salary.sort_by{|l| l[1].nil? ? 0 : l[1].expected_points }.last[1]

    end

=begin

=end


  end
end

