# == Schema Information
#
# Table name: player_costs
#
#  id               :integer          not null, primary key
#  player_id        :integer
#  game_id          :integer
#  site_id          :integer
#  position         :string(255)
#  salary           :integer
#  created_at       :datetime
#  updated_at       :datetime
#  expected_points  :float
#  actual_points_dk :float
#  healthy          :boolean          default(TRUE)
#  starting         :boolean          default(FALSE)
#  user_id          :integer
#

class PlayerCost < ActiveRecord::Base

  belongs_to :site
  belongs_to :player
  belongs_to :game

  scope :point_guards , -> { where(:position => "PG") }
  scope :shooting_guards , -> { where(:position => "SG") }
  scope :small_forwards, -> { where(:position => "SF") }
  scope :power_forwards, -> { where(:position => "PF") }
  scope :centers, -> { where(:position => "C") }
  scope :guards , -> { where("position = ? or position = ?", "PG", "SG") }
  scope :forwards, -> { where("position = ? or position = ?", "PF", "SF") }
  scope :primary, -> { where(position: ["PG", "SG", "SF", "PF", "C"]) }
  scope :starting, -> { where(starting: true) }
  scope :healthy, -> { where(healthy: true) }
  scope :positive, -> { where("expected_points > 0") }
  scope :no_user, -> { where(user_id: nil) }
  scope :for_user, lambda{ |user_id| where(user_id: user_id) }

  scope :from_games, lambda{ |game_ids| where(game_id: game_ids) }

  attr_accessor :weight_slope
  attr_accessor :locked
  attr_accessor :current_salary_difference
  attr_accessor :expected_points_difference
  attr_accessor :prev_lineup_cost

  def set_expected_points!(date=nil, nba_avgs, opponent_avgs, dk_average)
    date ||= self.game.date
    lookback = 3
    beginning_of_season = Date.new(2014, 10, 27)
    stat_lines = self.player.stat_lines.after_date(beginning_of_season).before_date(date).take(lookback)
    if stat_lines.length <= 2
      self[:expected_points] = 0
    elsif stat_lines.length == 1
      self[:expected_points] = stat_lines.first.score_draft_kings
    elsif stat_lines.length == 2
      self[:expected_points] = (stat_lines.first.score_draft_kings + stat_lines.last.score_draft_kings)/2.0
    else
      len = stat_lines.length
      sum = stat_lines.map(&:score_draft_kings).sum
      self[:expected_points] = sum / len
      sorted = stat_lines.map(&:score_draft_kings).sort
      median = len % 2 == 1 ? sorted[len/2] : (sorted[len/2 - 1] + sorted[len/2]).to_f / 2
      worst = sorted.first
      self[:expected_points] = (median + worst) / 2.0
#      self[:expected_points] = sorted.first

=begin
      average = (nba_avgs[self.position] + opponent_avgs[self.position]) / 2.0
      difference = opponent_avgs[self.position] - nba_avgs[self.position]
      scale_for_opponent = difference / average
      self[:expected_points] += self[:expected_points] * scale_for_opponent
=end

    end
    self.save
  end

=begin
  def set_expected_points!
    date = self.game.date
    beginning_of_season = Date.new(2014, 10, 27)
    stat_lines = self.player.stat_lines.after_date(beginning_of_season).before_date(date)
    if stat_lines.length == 0
      self[:expected_points] = 0
    elsif stat_lines.length == 1
      self[:expected_points] = stat_lines.first.score_draft_kings
    elsif stat_lines.length == 2
      self[:expected_points] = (stat_lines.first.score_draft_kings + stat_lines.last.score_draft_kings)/2.0
    else
      self[:expected_points] = stat_lines[(stat_lines.length/2.0).round].score_draft_kings#stat_lines.map(&:score_draft_kings).sum / stat_lines.length#
    end
    self.save
  end

  def set_expected_points!(lookback)
    date = self.game.date
    beginning_of_season = Date.new(2014, 10, 27)
    stat_lines = [self.player.stat_lines.after_date(beginning_of_season).before_date(date).take(lookback).last].compact
    if stat_lines.length == 0
      self[:expected_points] = 0
    elsif stat_lines.length == 1
      self[:expected_points] = stat_lines.first.score_draft_kings
    elsif stat_lines.length == 2
      self[:expected_points] = (stat_lines.first.score_draft_kings + stat_lines.last.score_draft_kings)/2.0
    else
      self[:expected_points] = stat_lines.map(&:score_draft_kings).sum / stat_lines.length#stat_lines[(stat_lines.length/2.0).round].score_draft_kings
    end
    self.save
  end
=end

  def actual_points_dk
    if self[:actual_points_dk].nil?
      stat_line = StatLine.find_by_game_id_and_player_id(self.game.id, self.player.id)
      if stat_line
        self[:actual_points_dk] = stat_line.score_draft_kings
        self.save
      else
        return 0
      end
    end
    self[:actual_points_dk]
  end

  def points
    self.expected_points
  end

  def primary?
    self.pg? || self.sg? || self.sf? || self.pf? || self.c?
  end

  def sg?
    self.position == "SG"
  end

  def pg?
    self.position == "PG"
  end

  def g?
    self.position == "G"
  end

  def sf?
    self.position == "SF"
  end

  def pf?
    self.position == "PF"
  end

  def f?
    self.position == "F"
  end

  def c?
    self.position == "C"
  end

  def u?
    self.position == "U"
  end

  def lower_position
    if self.pg? || self.sg?
      "G"
    elsif self.sf? || self.pf?
      "F"
    else
      "U"
    end
  end

  def expected_points_per_dollar
    self.expected_points / self.salary
  end

  def to_json
    data = {}
    data[:position] = self.position
    data[:salary] = self.salary
    data[:expected_points] = self.expected_points
    data[:actual_points] = self.actual_points_dk
    data[:healthy] = self.healthy
    data[:starting] = self.starting
    data[:player] = self.player.to_json
    data
  end

  def self.import_for_user_dk(filename, date, user=nil)
    require 'csv'
    date_string = date.strftime('%F')
    site = Site.find_by_name("Draft Kings")
    CSV.foreach(filename, {headers: true}) do |row|
      position = row[0]
      full_name = row[1].split(' ')
      first_name = full_name[0]
      last_name = full_name[1..-1].join(' ')
      player = Player.find_by_first_name_and_last_name(first_name, last_name)
      if player.nil?
        Rails.logger.info "Cannot find player with name: #{row[1]}"
        next
      end
      game = Game.where(date: date_string).where('home_team_id=? OR away_team_id=?', player.team_id, player.team_id).first
      if game.nil?
        Rails.logger.info "Cannot find game for date #{date} and player #{player.inspect}"
        next
      end
      salary = row[2]
      if user.nil? #if from salary update
        sinfo = site.player_costs.where(player_id: player.id, game_id: game.id).first_or_create
      else
        sinfo = site.player_costs.where(player_id: player.id, game_id: game.id, user_id: user.id).first_or_create
      end
      sinfo.position = position
      sinfo.salary = salary
      sinfo.save
      sinfo.expected_points = row[-1].to_f #sinfo.player.avg_draft_kings
      sinfo.save
    end
  end

  def self.import_for_user_fd(filename, date, user=nil)
    require 'csv'
    date_string = date.strftime('%F')
    site = Site.find_by_name("Fan Duel")

    CSV.foreach(filename) do |row|
      position = row[0]
      full_name = row[1].split(' ')
      first_name = full_name[0]
      last_name = full_name[1..-1].join(' ')
      player = Player.find_by_first_name_and_last_name(first_name, last_name)
      if player.nil?
        Rails.logger.info "Cannot find player with name: #{row[1]}"
        next
      end
      game = Game.where(date: date_string).where('home_team_id=? OR away_team_id=?', player.team_id, player.team_id).first
      if game.nil?
        Rails.logger.info "Cannot find game for date #{date} and player #{player.inspect}"
        next
      end
      salary = row[5].gsub(/\D/,'').to_i
      sinfo = site.player_costs.where(player_id: player.id, game_id: game.id).first_or_create
      sinfo.position = position
      sinfo.salary = salary
      sinfo.save
      sinfo.expected_points = row[2].to_f #sinfo.player.avg_draft_kings
      sinfo.save
    end

  end

end
