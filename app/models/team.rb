# == Schema Information
#
# Table name: teams
#
#  id           :integer          not null, primary key
#  nickname     :string(255)
#  city         :string(255)
#  abbreviation :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  nba_id       :integer
#  division_id  :integer
#  alt_nickname :string(255)
#

class Team < ActiveRecord::Base

  belongs_to :division

  has_many :home_games, :class_name => "Game", :foreign_key => 'home_team_id'
  has_many :away_games, :class_name => "Game", :foreign_key => 'away_team_id'
  has_many :players

  validates :nba_id, uniqueness: true

  def full_name
    "#{self.city} #{self.nickname}"
  end

  def points_given_by_position(date=nil)
    date ||= Date.today
    pts_given = []

    self.home_games.this_season.where("date < ?", date).each do |hg|
      pts_given << hg.home_team_against_position
    end
    self.away_games.this_season.where("date < ?", date).each do |hg|
      pts_given << hg.away_team_against_position
    end

    against = {}
    len = pts_given.length
    against['PG'] = pts_given.inject(0) {|sum, hash| sum + hash['PG']} / len
    against['SG'] = pts_given.inject(0) {|sum, hash| sum + hash['SG']} / len
    against['SF'] = pts_given.inject(0) {|sum, hash| sum + hash['SF']} / len
    against['PF'] = pts_given.inject(0) {|sum, hash| sum + hash['PF']} / len
    against['C'] = pts_given.inject(0) {|sum, hash| sum + hash['C']} / len
    return against
  end

  def games
    all_games = self.home_games + self.away_games
    all_games.sort_by!(&:date).reverse!
  end

  def self.nba_average_pgbp(date=nil)
    date ||= Date.today
    pts_given = []

    self.all.each do |t|
      pts_given << t.points_given_by_position(date)
    end

    against = {}
    len = pts_given.length
    against['PG'] = pts_given.inject(0) {|sum, hash| sum + hash['PG']} / len
    against['SG'] = pts_given.inject(0) {|sum, hash| sum + hash['SG']} / len
    against['SF'] = pts_given.inject(0) {|sum, hash| sum + hash['SF']} / len
    against['PF'] = pts_given.inject(0) {|sum, hash| sum + hash['PF']} / len
    against['C'] = pts_given.inject(0) {|sum, hash| sum + hash['C']} / len
    return against
  end

end
