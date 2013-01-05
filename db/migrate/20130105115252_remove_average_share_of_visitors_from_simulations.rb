class RemoveAverageShareOfVisitorsFromSimulations < ActiveRecord::Migration
  def up
    remove_column :simulations, :average_share_of_visitors
  end

  def down
    add_column :simulations, :average_share_of_visitors, :integer
  end
end
