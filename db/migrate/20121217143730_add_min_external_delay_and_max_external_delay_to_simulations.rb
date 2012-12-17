class AddMinExternalDelayAndMaxExternalDelayToSimulations < ActiveRecord::Migration
  def change
    add_column :simulations, :min_external_delay, :integer
    add_column :simulations, :max_external_delay, :integer
  end
end
