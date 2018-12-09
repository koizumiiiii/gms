namespace :batch do
  require "line/line_notify.rb"
  include LineNotify

  desc "GMSアプリで使用するバッチ処理"

  task :post_line => :environment do
    post_line
  end
end
