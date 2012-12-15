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
        events: [
          {
            type: "people-change",
            at: 0,
            data: {
              region: "platform-15",
              count: 123
            }
          },
          {
            type: "train-change",
            at: 50,
            data: {
              scheduledAt: "12:30",
              from: "Wroclaw",
              to: "Przemysl",
              delay: 420,
              platform: {
                new: 15,
                old: 12
              }
            }
          },
          {
            type: "train-semaphore-departure",
            at: 100,
            data: {
              train: "train-1",
              from: "Wroclaw",
              to: "Przemysl",
              count: 300,
              platform: 15,
              rail: 2,
              duration: 600,
              delay: {
                external: 70,
                semaphore: 0
              }
            }
          },
          {
            type: "waiting-trains-change",
            at: 200,
            data: {
              platform: 15,
              rail: 1,
              count: 1
            }
          },
          {
            type: "waiting-trains-change",
            at: 400,
            data: {
              platform: 15,
              rail: 1,
              count: 0
            }
          },
          {
            type: "people-change",
            at: 700,
            data: {
              region: "train-1",
              count: 250
            }
          },
          {
            type: "people-change",
            at: 700,
            data: {
              region: "platform-15",
              count: 173
            }
          },
          {
            type: "train-platform-departure",
            at: 800,
            data: {
              train: "train-1",
              delay: {
                external: 70,
                internal: 20
              }
            }
          }
        ],
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