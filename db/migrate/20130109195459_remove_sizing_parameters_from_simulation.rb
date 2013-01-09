class RemoveSizingParametersFromSimulation < ActiveRecord::Migration
  def up
    change_table :simulations do |t|
      t.remove :hall_length
      t.remove :hall_width
      t.remove :subway_length
      t.remove :subway_width
      t.remove :crowd_speed_distribution
    end
  end

  def down
    change_table :simulations do |t|
      t.float :hall_length
      t.float :hall_width
      t.float :subway_length
      t.float :subway_width
      t.binary :crowd_speed_distribution
    end
  end
end
