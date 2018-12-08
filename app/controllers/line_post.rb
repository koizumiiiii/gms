module BatchTest
  def post_line
    logger = Logger.new('log/batch_post_line.log')
    logger.info("start post_line batch");

    target_datetime_start_at = Time.now
    target_datetime_end_at = target_datetime_start_at.since(16.days)
    tasks = Task.where(start_at: target_datetime_start_at..target_datetime_end_at).order(:start_at)
    logger.debug("query dump : #{tasks.to_sql}");

    messages = []
    Task.skip_callback(:save, :before, :update_wether_information)
    tasks.each do |task|
      if task.start_at < target_datetime_start_at.since(1.day)
        messages << "[#{task.start_at.strftime('%H:%M')}] #{task.title}\n#{task.detail}"
      end
      if task.update_wether_information
        task.save
      end
    end
    Task.set_callback(:save, :before, :update_wether_information)
    logger.info("message count : #{messages.size}");

    if messages.size > 0
      post_message = "\n== 本日のタスク ===\n\n" + messages.join("\n\n");

      # post line
      logger.info("--- post message ---\n#{post_message}");
      
      uri = URI.parse("https://notify-api.line.me/api/notify")
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      
      req = Net::HTTP::Post.new(uri.request_uri)
      req["Authorization"] = "Bearer HnAsop8EOwkgNMYEa9OIklcon6NGpJ6JqbpFc4fOL2h"
      req["Content-Type"] = 'application/x-www-form-urlencoded;charset=UTF-8'
      req.set_form_data({message: post_message})
      
      res = https.request(req)
    end

    logger.info("finished post_line batch");
  end
end