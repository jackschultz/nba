class SitesController < ApplicationController

  def index
    @sites = Site.all
  end

  def show
    @site = Site.find(params[:id])
    beginning_of_season = Date.new(2014, 10, 27)
    @dates = Date.today.downto(beginning_of_season)
  end

  private

end
