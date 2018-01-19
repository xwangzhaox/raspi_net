require 'open-uri'
require "net/http"
require "json"
module Base
  module Http
    def _post(url, params)
      uri = URI(url)
      req = ::Net::HTTP::Post.new(uri, {'Content-Type' => 'application/json'})
      req.set_form_data(params)
      begin
        res = ::Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(req)
        end
      rescue
        @logger.error("Post request(#{url})Error:#{$!} at:#{$@}")
      end
      respond = JSON.parse(res.body)
      @logger.info("Post request:#{url}---Respond:#{respond}")
      respond
    end

    def _get(url)
      uri = URI(url)
      begin
        res = ::Net::HTTP.get(uri)
      rescue
        @logger.error("Get request(#{url})Error:#{$!} at:#{$@}")
      end
      respond = JSON.parse(res)
      @logger.info("Get request:#{url}---Respond:#{respond}")
      respond
    end
  end
end
