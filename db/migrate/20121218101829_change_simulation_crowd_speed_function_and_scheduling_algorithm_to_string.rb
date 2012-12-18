class ChangeSimulationCrowdSpeedFunctionAndSchedulingAlgorithmToString < ActiveRecord::Migration
  def up
    change_column :simulations, :crowd_speed_function, :string
    change_column :simulations, :scheduling_algorithm, :string
    Simulation.update_all('crowd_speed_function = null, scheduling_algorithm = null')
  end

  def down
    change_column :simulations, :crowd_speed_function, :integer
    change_column :simulations, :scheduling_algorithm, :integer
    Simulation.update_all('crowd_speed_function = null, scheduling_algorithm = null')
  end
end
