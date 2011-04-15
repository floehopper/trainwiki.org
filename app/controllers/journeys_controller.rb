class JourneysController < ApplicationController

  def index
    if params[:date].present?
      @date = Date.parse(params[:date])
      @journeys = Journey.departs_on(@date).includes(:origin_station, :destination_station).order(:departs_at)
    else
      redirect_to journeys_path(:date => Date.today)
    end
  end

  def show
    unless @journey = Journey.find_by_identifier(params[:id])
      @journey = Journey.find_canonical(params[:id])
      redirect_to journey_path(@journey), :status => :moved_permanently
    end
  end

end