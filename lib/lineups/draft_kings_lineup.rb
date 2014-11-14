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

    def actual_points_dk
      self.lineup.map(&:actual_points_dk).compact.sum
    end

    def lineup
      [@point_guard, @shooting_guard, @small_forward, @power_forward, @center, @guard, @forward, @utility].compact
    end

    def player_ids
      self.lineup.map(&:player_id)
    end

    def valid_players?
      player_ids.uniq.count == 8
    end

    def duplicates
      ids = self.player_ids
      duplicates = ids.select{|element| ids.count(element) > 1 }.uniq
      self.lineup.select{|d| duplicates.include?(d.player_id)}
    end

    def to_json
      data = {}
=begin
      data[:players] = {}
      data[:players][:point_guard] = self.point_guard.to_json
      data[:players][:shooting_guard] = self.shooting_guard.to_json
      data[:players][:small_forward] = self.small_forward.to_json
      data[:players][:power_forward] = self.power_forward.to_json
      data[:players][:center] = self.center.to_json
      data[:players][:guard] = self.guard.to_json
      data[:players][:forward] = self.forward.to_json
      data[:players][:utility] = self.utility.to_json
=end
      data[:players] = []
      self.lineup.each do |p|
        data[:players] << p.to_json
      end
      data[:expected_points] = self.expected_points
      data[:actual_points_dk] = self.actual_points_dk
      data[:salary] = self.current_cost
      data
    end

  end
end
