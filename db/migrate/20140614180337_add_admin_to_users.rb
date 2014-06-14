class AddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean, default: false #otherwise it would be default "nil", which would also be false a fortiori, but still, 
    # this is clearer
  end
end
