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
  end

  def result
    @simulation = Simulation.find(params[:id])
    unless @simulation.result.nil?
      # TODO! remove this static result
      render json: {
        events: [],
        summary: {
          cashDesks: {
            soldTickets: 1233,
            averageWaitingTime: 364
          },
          infoDesks: {
            servedInformations: 1047,
            complaints: 47,
            averageWaitingTime: 120
          },
          passengers: {
            arriving: 5000,
            departuring: 5100
          },
          companions: 200,
          visitors: 1300,
          trains: {
            count: 40,
            platformChanges: 4,
            delay: {
              average: {
                semaphore: 247,
                platform: 116,
                external: 758
              }
            }
          }
        }
      } and return
      render json: @simulation.result.to_json
    else
      render json: { message: 'Simulation is still being computed.' }, status: 202 # still processing
    end
  end
end