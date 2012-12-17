class ReplaceMinAndMaxInternalArrivalTimeWithInternalArrivalTime < ActiveRecord::Migration
  def up
    rename_column :simulations, :min_internal_arrival_time, :internal_arrival_time
    remove_column :simulations, :max_internal_arrival_time
  end

  def down
    add_column :simulations, :max_internal_arrival_time, :integer
    Simulation.connection.execute "update simulations set max_internal_arrival_time = internal_arrival_time"
    rename_column :simulations, :internal_arrival_time, :min_internal_arrival_time
  end
end
