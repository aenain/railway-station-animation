class AddAverageProbabilityOfExternalDelayToSimulations < ActiveRecord::Migration
  def change
    add_column :simulations, :average_probability_of_external_delay, :integer
  end
end
