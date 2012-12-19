class SimulationsController < ApplicationController
  def new
    @simulation = Simulation.build_with_defaults
  end

  def create
    @simulation = Simulation.new(params[:simulation])
    if @simulation.save
      @simulation.simulate
      redirect_to @simulation
    else
      render :new
    end
  end

  def show
    @simulation = Simulation.find(params[:id])
    @acceleration = 100
  end

  def result
    @simulation = Simulation.find(params[:id])
    unless @simulation.result.nil?
      render json: @simulation.result.to_json
    else
      render json: { message: 'Simulation is still being computed.' }, status: 202 # still processing
    end
  end
end