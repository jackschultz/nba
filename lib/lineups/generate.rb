module Lineups
  module Generate

=begin
    def self.generate_lineups(player_costs)
      lineups = []
      player_costs.each_index do |index|
        lineup = DraftKingsLineup.new(total_salary: 50000)
        potential_lineups = test_player_cost(lineup, player_costs[index..-1])
        lineups += potential_lineups
        puts "Num lineups: #{potential_lineups.count}"
        binding.pry
      end

      binding.pry
      lineups.sort!{|a,b| b.expected_points <=> a.expected_points};
      return lineups
    end

    def self.test_player_cost(lineup, pcs)
      min_salary = 3000
      pcs = pcs.map{|pc| lineup.available_positions.include?(pc.position) ? pc : nil}.compact
      if lineup.complete? || pcs.empty? || (lineup.total_salary - lineup.current_cost) < min_salary
        return [lineup]
      else
        lineup.add_player_cost(pcs.first)
        # remove all where positions are already present
        potential_lineups = []
        pcs.each_index do |index|
          #return test_player_cost(lineup, pcs[1..-1])
          puts "new lineup #{index}"
          potential_lineups += test_player_cost(clone_lineup(lineup), pcs[index+1..-1])
        end
        return potential_lineups
      end
    end

    def self.clone_lineup(lineup)
      new_lineup = DraftKingsLineup.new(total_salary: 50000)
      new_lineup.players = lineup.players.clone
      new_lineup.available_positions = lineup.available_positions.clone
      new_lineup
    end
=end

    def self.filter_player_list(lineup, players)
      current_player_ids = lineup.player_ids
      players.select{|p| current_player_ids.exclude?(p.player_id)}
    end

    def self.filter_player_cost(lineup, players)
      remaining_cost = lineup.remaining_cost
      players.select{|p| p.salary < remaining_cost}
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

      chop_size = 2

      pgcount = point_guards.length
      point_guards.sort_by!{|p| p.expected_points}.reverse
      point_guards = point_guards[0..(pgcount.to_f/chop_size).round]

      sgcount = shooting_guards.length
      shooting_guards.sort_by!{|p| p.expected_points}.reverse
      shooting_guards = shooting_guards[0..(sgcount.to_f/chop_size).round]

      pfcount = power_forwards.length
      power_forwards.sort_by!{|p| p.expected_points}.reverse
      power_forwards = power_forwards[0..(pfcount.to_f/chop_size).round]

      sfcount = small_forwards.length
      small_forwards.sort_by!{|p| p.expected_points}.reverse
      small_forwards = small_forwards[0..(sfcount.to_f/chop_size).round]

      ccount = centers.length
      centers.sort_by!{|p| p.expected_points}.reverse
      centers = centers[0..(ccount.to_f/chop_size).round]

      gcount = guards.length
      guards.sort_by!{|p| p.expected_points}.reverse
      guards = guards[0..(gcount.to_f/chop_size).round]

      fcount = forwards.length
      forwards.sort_by!{|p| p.expected_points}.reverse
      forwards = forwards[0..(fcount.to_f/chop_size).round]

      ucount = utilities.length
      utilities.sort_by!{|p| p.expected_points}.reverse
      utilities = utilities[0..(ucount.to_f/chop_size).round]

      binding.pry

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
    end

  end
end
