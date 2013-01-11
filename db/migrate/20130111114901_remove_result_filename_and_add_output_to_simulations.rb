class RemoveResultFilenameAndAddOutputToSimulations < ActiveRecord::Migration
  def up
    remove_column :simulations, :result_filename
    add_column :simulations, :output, :string
  end

  def down
    remove_column :simulations, :output
    add_column :simulations, :result_filename, :string
  end
end
