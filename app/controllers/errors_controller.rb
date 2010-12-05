class ErrorsController < ApplicationController
  def index
    @errors = Error.all
  end

  def show
    @error = Error.find(params[:id])
    render :text => @error.page_html
  end
end