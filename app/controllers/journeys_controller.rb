class JourneysController < ApplicationController

  def index
    @journeys = Journey.includes(
      :origin_departure => :station,
      :destination_arrival => :station
    ).all.sort_by { |j| j.departs_at }
  end

  def show
    unless @journey = Journey.find_by_identifier(params[:id])
      @journey = Journey.find_canonical(params[:id])
      redirect_to journey_path(@journey), :status => :moved_permanently
    end
  end

end