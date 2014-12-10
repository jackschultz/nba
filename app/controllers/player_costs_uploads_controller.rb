class PlayerCostsUploadsController < ApplicationController

  before_action :set_site
  before_action :set_date

  def create
    file = params[:projections]
    if !file.nil?
      filename = file.path
      if @site.fan_duel?
        PlayerCost.import_for_user_fd(filename, @date, current_user)
      elsif @site.draft_kings?
        PlayerCost.import_for_user_dk(filename, @date, current_user)
      end
      redirect_to site_games_date_path(site_id: @site.id, year: @date.year, month: @date.month, day: @date.day)
    else
      redirect_to site_games_date_path(site_id: @site.id, year: @date.year, month: @date.month, day: @date.day)
    end
  end

  private

  def set_date
    @date = Date.new(params[:year].to_i,params[:month].to_i,params[:day].to_i)
  end

  def set_site
    @site = Site.find(params[:site_id])
  end

end
