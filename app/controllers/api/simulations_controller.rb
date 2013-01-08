class Api::SimulationsController < Api::BaseController
  def create
    @simulation = Simulation.new(params[:simulation])
    if @simulation.save
      render json: { data: { simulation: { id: @simulation.reload.id } } }
    else
      render json: { error: { code: 422, status: "unprocessable entity" } }, status: 422
    end
  end

  def show
    rescue_from_not_found do
      @simulation = Simulation.find(params[:id])
      render json: @simulation
    end
  end

  def update
    rescue_from_not_found do
      @simulation = Simulation.find(params[:id])
      @simulation.attributes = params[:simulation]
      if @simulation.save
        render json: { data: { simulation: { id: @simulation.id } } }
      else
        render json: { error: { code: 422, status: "unprocessable entity" } }, status: 422
      end
    end
  end

  def upload_json
    upload_result
  end

  def upload_gzip
    upload_result
  end

  private

  def upload_result
    rescue_from_not_found do
      @simulation = Simulation.find(params[:id])
      @simulation.save_result_from_io(params[:result])
      render json: { data: { simulation: { id: @simulation.id } } }
    end
  end

  def rescue_from_not_found
    begin
      yield
    rescue ActiveRecord::RecordNotFound
      render json: { error: { code: 404, status: "not found" } }, status: 404
    end
  end
end