class ChangeTypeOfSizingParametersToFloat < ActiveRecord::Migration
  
  def up
    change_columns do |column|
      change_column :simulations, column, :float
    end
  end

  def down
    change_columns do |column|
      change_column :simulations, column, :integer
    end
  end

  private

  def change_columns
    [:hall_width, :hall_length, :subway_width, :subway_length].each do |column|
      yield column
    end
  end
end
