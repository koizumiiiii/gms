class Task < ApplicationRecord
  OPENWEATHERMAP_APPID = "1e9b36a73fd78e6e992a39e7c2183393"
  OPENWEATHERMAP_API = "http://api.openweathermap.org/data/2.5/find"

  validates :title, :start_at, presence: true
  validate :check_start_at

  before_save do
    update_wether_information
    return true
  end

  def check_start_at
    if start_at.present? && start_at < Time.now
      errors.add(:start_at, "過去の時間は指定できません")
    end
  end

  def update_wether_information

    return if latitude.blank? || longitude.blank?

    days = ((start_at.beginning_of_day - Time.now.beginning_of_day) / (60 * 60 * 24)).to_i
    return if days < 0 || 15 < days

    # hash形式でパラメタ文字列を指定し、URL形式にエンコード
    api_params = URI.encode_www_form({
      lat: latitude,
      lon: longitude,
      cnt: days + 1,
      appid: OPENWEATHERMAP_APPID
    })
    # URIを解析し、hostやportをバラバラに取得できるようにする
    uri = URI.parse("#{OPENWEATHERMAP_API}?#{api_params}")
    # リクエストパラメタを、インスタンス変数に格納
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      # 接続時に待つ最大秒数を設定
      http.open_timeout = 5
      # 読み込み一回でブロックして良い最大秒数を設定
      http.read_timeout = 10
      # ここでWebAPIを叩いている
      # Net::HTTPResponseのインスタンスが返ってくる
      http.get(uri.request_uri)
    end
    begin
      # responseの値に応じて処理を分ける
      case response
      # 成功した場合
      when Net::HTTPSuccess
        weather_infomation = response.body

        # responseのbody要素をJSON形式で解釈し、hashに変換
        @result = JSON.parse(response.body)
        # 表示用の変数に結果を格納
        # @zipcode = @result["results"][0]["zipcode"]
        # @address1 = @result["results"][0]["address1"]
        # @address2 = @result["results"][0]["address2"]
        # @address3 = @result["results"][0]["address3"]
      # 別のURLに飛ばされた場合
      when Net::HTTPRedirection
        @message = "Redirection: code=#{response.code} message=#{response.message}"
      # その他エラー
      else
        @message = "HTTP ERROR: code=#{response.code} message=#{response.message}"
      end
    # エラー時処理
    rescue IOError => e
      @message = e.message
    rescue TimeoutError => e
      @message = e.message
    rescue JSON::ParserError => e
      @message = e.message
    rescue => e
      @message = e.message
    end

  end
end
