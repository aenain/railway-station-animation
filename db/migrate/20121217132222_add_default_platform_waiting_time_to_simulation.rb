class AddDefaultPlatformWaitingTimeToSimulation < ActiveRecord::Migration
  def change
    add_column :simulations, :default_platform_waiting_time, :integer
  end
end
