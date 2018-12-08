namespace :batch do
  require "./app/controllers/line_post.rb"
  include BatchTest

  desc "GMSアプリで使用するバッチ処理"

  task :post_line => :environment do
    post_line
  end
end
