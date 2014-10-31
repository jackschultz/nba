module Lineups
  class Lineup

    attr_reader :total_salary
    attr_accessor :players
    attr_accessor :available_positions

    def initialize(opts={})
    end

    def expected_points
      @players.map(&:expected_points).compact.inject(:+) || 0
    end

    def current_cost
      @players.map(&:salary).inject(:+) || 0
    end

    def valid_player_cost(player_cost)
      if self.current_cost + player_cost.salary < @total_salary && @available_positions.include?(player_cost.position) && !@players.map(&:player_id).include?(player_cost.player_id)
        true
      else
        false
      end
    end

    def add_player_cost(player_cost)
      if valid_player_cost(player_cost)
        @players << player_cost
        @available_positions.delete(player_cost.position)
      end
    end

    def complete?
      @available_positions.empty?
    end

  end
end
