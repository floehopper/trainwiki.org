class JourneysController < ApplicationController

  def index
    if params[:date].present?
      @date = Date.parse(params[:date])
      @journeys = Journey.departs_on(@date).includes(:origin_station, :destination_station).order(:departs_at)
      @previous_journeys = Journey.departs_on(@date - 1).any?
      @next_journeys = Journey.departs_on(@date + 1).any?
    else
      redirect_to journeys_path(:date => Date.today)
    end
  end

  def show
    if @journey = Journey.find_by_identifier(params[:id])
      @previous_journey = @journey.previous
      @next_journey = @journey.next
    else
      @journey = Journey.find_canonical(params[:id])
      redirect_to journey_path(@journey), :status => :moved_permanently
    end
  end

end