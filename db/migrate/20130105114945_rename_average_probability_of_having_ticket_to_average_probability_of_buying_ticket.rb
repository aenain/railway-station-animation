class RenameAverageProbabilityOfHavingTicketToAverageProbabilityOfBuyingTicket < ActiveRecord::Migration
  def change
    rename_column :simulations, :average_probability_of_having_ticket, :average_probability_of_buying_ticket
  end
end
