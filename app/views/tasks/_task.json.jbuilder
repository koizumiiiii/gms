json.extract! task, :id, :title, :detail, :start_at, :weather_infomation, :place, :latitude, :longitude, :created_at, :updated_at
json.url task_url(task, format: :json)
