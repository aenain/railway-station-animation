class AddMinCompanionComingTimeSpanAndMaxCompanionComingTimeSpanToSimulations < ActiveRecord::Migration
  def change
    add_column :simulations, :min_companion_coming_time_span, :integer
    add_column :simulations, :max_companion_coming_time_span, :integer
  end
end
