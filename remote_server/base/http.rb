module Http
  def _post(url, params)
    uri = URI(url)
    req = Net::HTTP::Post.new(uri, {'Content-Type' => 'application/json'})
    req.set_form_data(params)
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    JSON.parse(res.body)
  end

  def _get(url)
    uri = URI(url)
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end
end
