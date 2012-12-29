class RemoveResultOfSimulationsAndAddResultFilename < ActiveRecord::Migration
  def up
    remove_column :simulations, :result
    add_column :simulations, :result_filename, :string
  end

  def down
    add_column :simulations, :result, :binary, limit: 16.megabyte
    remove_column :simulations, :result_filename
  end
end
