class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :detail
      t.datetime :start_at
      t.text :weather_infomation
      t.string :place
      t.float :latitude, percision: 10, scale: 6
      t.float :longitude, percision: 10, scale: 6

      t.timestamps
    end
  end
end
