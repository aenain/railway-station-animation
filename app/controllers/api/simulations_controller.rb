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
    upload_result do |path|
      Zlib::GzipWriter.open(path) do |gz|
        gz.write(params[:result].read)
      end
    end
  end

  def upload_gzip
    upload_result do |path|
      File.open(path, 'w') do |f|
        f.write(params[:result].read.force_encoding('utf-8'))
      end
    end
  end

  private

  def upload_result(&block)
    rescue_from_not_found do
      @simulation = Simulation.find(params[:id])
      path = @simulation.build_result_path
      block.call(path)
      @simulation.update_column(:result_filename, path.basename.to_s)
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