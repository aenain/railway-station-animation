class Api::SimulationsController < Api::BaseController
  def create
    @simulation = Simulation.new(params[:simulation])
    if @simulation.save
      render json: { data: { simulation: { id: @simulation.reload.id } } }
    else
      render json: { error: { code: 422, status: "unprocessable entity" } }, status: 422
    end
  end

  def upload_json
    @simulation = Simulation.find(params[:id])
    path = @simulation.build_result_path

    Zlib::GzipWriter.open(path) do |gz|
      gz.write(params[:result].read)
    end

    @simulation.update_column(:result_filename, path.basename.to_s)
    render json: { data: { simulation: { id: @simulation.id } } }
  end

  def upload_gzip
    @simulation = Simulation.find(params[:id])
    path = @simulation.build_result_path

    File.open(path, 'w') do |f|
      f.write(params[:result].read.force_encoding('utf-8'))
    end

    @simulation.update_column(:result_filename, path.basename.to_s)
    render json: { data: { simulation: { id: @simulation.id } } }
  end
end