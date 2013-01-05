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
      flash[:error] = "Error: #{@simulation.errors.full_messages.join(', ')}"
      render :new
    end
  end

  def show
    @simulation = Simulation.find(params[:id])
    @acceleration = 100
  end

  def result
    @simulation = Simulation.find(params[:id])
    if @simulation.computed?
      response.headers['Content-Type'] = 'application/json; charset=utf-8'
      if request.headers['Accept-Encoding'] =~ /gzip/
        response.headers['Content-Encoding'] = 'gzip'
        render text: @simulation.result
      else
        render text: @simulation.decompress_result
      end
    else
      render json: { message: 'Simulation is still being computed.' }, status: 202 # still processing
    end
  end
end