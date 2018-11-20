class ChangeLatLon < ActiveRecord::Migration[5.2]
  def change
    change_column :tasks, :latitude, :decimal, precision: 11, scale: 8
    change_column :tasks, :longitude, :decimal, precision: 11, scale: 8
    change_column :tasks, :temperature, :decimal, precision: 3, scale: 1
  end
end
