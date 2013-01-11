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

  def export_dialog
    @simulation = Simulation.find(params[:id])
    @package_size = Yetting.simulation_package_size
  end

  def export_parameters
    @simulation = Simulation.find(params[:id])
    send_data JSON.pretty_generate(@simulation.as_json), type: 'application/json; charset=utf-8',
                                                         disposition: 'attachment; filename=config.json'
  end

  def import_result
    @simulation = Simulation.find(params[:id])
    if @simulation.update_attributes(params[:simulation])
      redirect_to @simulation
    else
      render :export_dialog
    end
  end

  def show
    @simulation = Simulation.find(params[:id])
    @acceleration = 100
    redirect_to export_dialog_simulation_path(@simulation) unless @simulation.computed?
  end

  def result
    @simulation = Simulation.find(params[:id])

    if @simulation.computed?
      response.headers['Content-Type'] = 'application/json; charset=utf-8'
      if request.headers['Accept-Encoding'] =~ /gzip/
        response.headers['Content-Encoding'] = 'gzip'
        render text: @simulation.compress_result
      else
        render text: @simulation.decompress_result
      end
    else
      render json: { message: 'Simulation is still being computed.' }, status: 202 # still processing
    end
  end
end