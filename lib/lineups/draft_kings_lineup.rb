module Lineups
  class DraftKingsLineup < Lineup

    attr_accessor :total_salary
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
      if opts[:player_cost_ids]
        pcids = opts[:player_cost_ids]
        @point_guard = PlayerCost.find(pcids[0])
        @shooting_guard = PlayerCost.find(pcids[1])
        @small_forward = PlayerCost.find(pcids[2])
        @power_forward = PlayerCost.find(pcids[3])
        @center = PlayerCost.find(pcids[4])
        @guard = PlayerCost.find(pcids[5])
        @forward = PlayerCost.find(pcids[6])
        @utility = PlayerCost.find(pcids[7])
      else
        @point_guard = nil
        @shooting_guard = nil
        @small_forward = nil
        @power_forward = nil
        @center = nil
        @guard = nil
        @forward = nil
        @utility = nil
      end

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

    def actual_points_dk
      self.lineup.map(&:actual_points_dk).compact.sum
    end

    def lineup
      [@point_guard, @shooting_guard, @small_forward, @power_forward, @center, @guard, @forward, @utility].compact
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

    def clone
      new_lineup = DraftKingsLineup.new
      new_lineup.total_salary = self.total_salary
      new_lineup.point_guard = self.point_guard.dup if self.point_guard
      new_lineup.shooting_guard = self.shooting_guard.dup if self.shooting_guard
      new_lineup.small_forward = self.small_forward.dup if self.small_forward
      new_lineup.power_forward = self.power_forward.dup if self.power_forward
      new_lineup.center = self.center.dup if self.center
      new_lineup.guard = self.guard.dup if self.guard
      new_lineup.forward = self.forward.dup if self.forward
      new_lineup.utility = self.utility.dup if self.utility
      return new_lineup
    end

    def add_player(new_player)
      if new_player.pg?
        if self.point_guard.nil?
          self.point_guard = new_player
        elsif self.guard.nil?
          self.guard = new_player
        elsif self.utility.nil?
          self.utility = new_player
        end
      elsif new_player.sg?
        if self.shooting_guard.nil?
          self.shooting_guard = new_player
        elsif self.guard.nil?
          self.guard = new_player
        elsif self.utility.nil?
          self.utility = new_player
        end
      elsif new_player.sf?
        if self.small_forward.nil?
          self.small_forward = new_player
        elsif self.forward.nil?
          self.forward = new_player
        elsif self.utility.nil?
          self.utility = new_player
        end
      elsif new_player.pf?
        if self.power_forward.nil?
          self.power_forward = new_player
        elsif self.forward.nil?
          self.forward = new_player
        elsif self.utility.nil?
          self.utility = new_player
        end
      elsif new_player.c?
        if self.center.nil?
          self.center = new_player
        elsif self.utility.nil?
          self.utility = new_player
        end
      end
    end

=begin
    def add_player(new_player)
      if player_in_lineup?(new_player)
        return nil
      else
        if new_player.pg?
          old_player = self.point_guard
          self.point_guard = new_player
        elsif new_player.sg?
          old_player = self.shooting_guard
          self.shooting_guard = new_player
        elsif new_player.sf?
          old_player = self.small_forward
          self.small_forward = new_player
        elsif new_player.pf?
          old_player = self.power_forward
          self.power_forward = new_player
        elsif new_player.c?
          old_player = self.center
          self.center = new_player
        elsif new_player.g?
          old_player = self.guard
          self.guard = new_player
        elsif new_player.f?
          old_player = self.forward
          self.forward = new_player
        elsif new_player.u?
          old_player = self.utility
          self.utility = new_player
        end
        return old_player
      end
    end

    def add_player(new_player)
      if new_player.pg?
        prev_player = self.point_guard
        self.point_guard = new_player
        if self.valid_cost?
          if !self.valid_players?
            self.small_forward = prev_player
          end
          return true
        else
          self.point_guard = prev_player
          return false
        end
      elsif new_player.sg?
        prev_player = self.shooting_guard
        self.shooting_guard = new_player
        if self.valid_cost?
          if !self.valid_players?
            self.small_forward = prev_player
          end
          return true
        else
          self.shooting_guard = prev_player
          return false
        end
      elsif new_player.sf?
        prev_player = self.small_forward
        self.small_forward = new_player
        if self.valid_cost?
          if !self.valid_players?
            self.small_forward = prev_player
          end
          return true
        else
          self.small_forward = prev_player
          return false
        end
      elsif new_player.pf?
        prev_player = self.power_forward
        self.power_forward = new_player
        if self.valid_cost?
          if !self.valid_players?
            self.small_forward = prev_player
          end
          return true
        else
          self.power_forward = prev_player
          return false
        end
      elsif new_player.c?
        prev_player = self.center
        self.center = new_player
        if self.valid_cost?
          if !self.valid_players?
            self.small_forward = prev_player
          end
          return true
        else
          self.center = prev_player
          return false
        end
      elsif new_player.g?
        prev_player = self.guard
        self.guard = new_player
        if self.valid_cost?
          if !self.valid_players?
            self.small_forward = prev_player
          end
          return true
        else
          self.guard = prev_player
          return false
        end
      elsif new_player.f?
        prev_player = self.forward
        self.forward = new_player
        if self.valid_cost?
          if !self.valid_players?
            self.small_forward = prev_player
          end
          return true
        else
          self.forward = prev_player
          return false
        end
      elsif new_player.u?
        prev_player = self.utility
        self.utility = new_player
        if self.valid_cost?
          if !self.valid_players?
            self.small_forward = prev_player
          end
          return true
        else
          self.utility = prev_player
          return false
        end
      end
    end
=end

  end
end
