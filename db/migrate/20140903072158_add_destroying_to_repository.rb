class AddDestroyingToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :destroying, :boolean, default: false, null: false
  end
end
