class JourneysController < ApplicationController

  def index
    @journeys = Journey.includes(
      :origin_departure => :station,
      :destination_arrival => :station
    ).all.sort_by { |j| j.departs_at }
  end

  def show
    @journey = Journey.where(:identifier => params[:id]).includes(:events => :station).first
  end

end