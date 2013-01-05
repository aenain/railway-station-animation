class SimulationParametersMakeOver < ActiveRecord::Migration
  def up
    change_table :simulations do |t|
      t.remove :max_companion_count
      t.remove :average_probability_of_having_companion
      t.remove :crowd_speed_function

      t.binary :companion_count_distribution
      t.binary :crowd_speed_distribution
      t.binary :visitor_coming_distribution
      t.integer :subway_width
      t.integer :subway_length
      t.integer :hall_width
      t.integer :hall_length
      t.integer :average_probability_of_getting_information
    end
  end

  def down
    change_table :simulations do |t|
      t.remove :companion_count_distribution
      t.remove :crowd_speed_distribution
      t.remove :visitor_coming_distribution
      t.remove :subway_width
      t.remove :subway_length
      t.remove :hall_width
      t.remove :hall_length
      t.remove :average_probability_of_getting_information

      t.integer :max_companion_count
      t.integer :average_probability_of_having_companion
      t.string :crowd_speed_function
    end
  end
end
