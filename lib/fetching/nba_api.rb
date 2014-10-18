module Fetching
  class NbaApi

    def self.build_conn
      endpoint = 'http://stats.nba.com'
      connection = Faraday.new(endpoint) do |co|
        co.request :url_encoded
        co.adapter  Faraday.default_adapter
      end
      connection
    end

    def self.conn
      @conn ||=build_conn
    end

    def self.fetch_from_nba(url, params = {})
      response = conn.get(url, params)
      if response.success?
        response.body
      else
        false
      end
    end

  end
end
