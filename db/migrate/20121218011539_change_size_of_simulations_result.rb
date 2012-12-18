class ChangeSizeOfSimulationsResult < ActiveRecord::Migration
  def up
    change_column :simulations, :result, :binary, limit: 16.megabyte 
  end

  def down
    change_column :simulations, :result, :binary, limit: 1.megabyte
  end
end
