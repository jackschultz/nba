module Lineups
  class FanDuelLineup < Lineup

    attr_accessor :total_salary
    attr_accessor :point_guard
    attr_accessor :point_guard2
    attr_accessor :shooting_guard
    attr_accessor :shooting_guard2
    attr_accessor :small_forward
    attr_accessor :small_forward2
    attr_accessor :power_forward
    attr_accessor :power_forward2
    attr_accessor :center

    def initialize(opts={})
      super(opts)
      @total_salary = 60000
      @point_guard = nil
      @point_guard2 = nil
      @shooting_guard = nil
      @shooting_guard2 = nil
      @small_forward = nil
      @small_forward2 = nil
      @power_forward = nil
      @power_forward2 = nil
      @center = nil

    end

    def valid?
      self.valid_cost? && self.valid_player_list?
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

    def actual_points_fd
      self.lineup.map(&:actual_points_fd).compact.sum
    end

    def lineup
      [@point_guard, @point_guard2, @shooting_guard, @shooting_guard2, @small_forward, @small_forward2, @power_forward, @power_forward2, @center].compact
    end

    def player_ids
      self.lineup.map(&:player_id)
    end

    def valid_player_list?
      player_ids.uniq.count == player_ids.count
    end

    def valid_players?
      player_ids.uniq.count == 8
    end

    def player_in_lineup?(player)
      player_ids.include?(player.player_id)
    end

    def duplicates
      ids = self.player_ids
      duplicates = ids.select{|element| ids.count(element) > 1 }.uniq
      self.lineup.select{|d| duplicates.include?(d.player_id)}
    end

    def to_json
      data = {}
      data[:players] = []
      self.lineup.each do |p|
        data[:players] << p.to_json
      end
      data[:expected_points] = self.expected_points
      data[:actual_points_dk] = self.actual_points_dk
      data[:salary] = self.current_cost
      data
    end

    def add_player(new_player)
      if new_player.pg?
        if self.point_guard.nil?
          self.point_guard = new_player
        elsif self.point_guard2.nil?
          self.point_guard2 = new_player
        end
      elsif new_player.sg?
        if self.shooting_guard.nil?
          self.shooting_guard = new_player
        elsif self.shooting_guard2.nil?
          self.shooting_guard2 = new_player
        end
      elsif new_player.sf?
        if self.small_forward.nil?
          self.small_forward = new_player
        elsif self.small_forward2.nil?
          self.small_forward2 = new_player
        end
      elsif new_player.pf?
        if self.power_forward.nil?
          self.power_forward = new_player
        elsif self.power_forward2.nil?
          self.power_forward2 = new_player
        end
      elsif new_player.c?
        if self.center.nil?
          self.center = new_player
        end
      end
    end
  end
end
