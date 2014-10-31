module Lineups
  class DraftKingsLineup < Lineup

    attr_accessor :point_guard
    attr_accessor :shooting_guard
    attr_accessor :small_forward
    attr_accessor :power_forward
    attr_accessor :center
    attr_accessor :guard
    attr_accessor :forward
    attr_accessor :utility

    def initialize(opts={})
      super(opts)
      @total_salary = 50000
      @point_guard = nil
      @shooting_guard = nil
      @small_forward = nil
      @power_forward = nil
      @center = nil
      @guard = nil
      @forward = nil
      @utility = nil
    end

    def remaining_cost
      @total_salary - self.current_cost
    end

    def valid_cost?
      self.current_cost < @total_salary
    end

    def current_cost
      self.lineup.map(&:salary).sum
    end

    def expected_points
      self.lineup.map(&:expected_points).sum
    end

    def lineup
      [@point_guard, @shooting_guard, @small_forward, @power_forward, @center, @guard, @forward, @utility].compact
    end

    def player_ids
      self.lineup.map(&:player_id)
    end

  end
end
