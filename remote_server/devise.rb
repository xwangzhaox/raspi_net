require 'yaml'
require_relative "./base/http"
class Devise
  include Base::Http
  SETTING_PATH= "/home/pi/workspace/remote_server/config.yml"

  def check_devise_state
    @setting = YAML.load_file(SETTING_PATH)
    respond = _get(@setting["interface"]["get_devise_list"]+"?space_code="+@setting["space_code"])
    redis = Redis.new(host:'127.0.0.1', port: 6379)
    get_online_devise(respond["devise_list"])
    online_devise = redis.exists("devise-online") && redis.hkeys("devise-online") do |code|
      return code if redis.hget("devise-online", code) == true
    end || []
    upload_online_state(online_devise)
  end

  def upload_online_state(codes)
    params = {:space_code => @setting["space_code"], :codes => codes}
    _post(@setting["interface"]["upload_node_online_state"], params)
  end

  # respond: {devise_list=>["3813jd", "93jd81"]} node code list
  def get_online_devise(codes=[])
    log_file = "/home/pi/workspace/remote_server/execute_cmd_log.log"
    server_file = "/home/pi/workspace/raspi_net/server/server1"
    codes.each do |devise|
      puts "Devise start: #{devise}"
      puts "sudo #{server_file} #{devise} ol > #{log_file}"
      `sudo #{server_file} #{devise} ol > #{log_file}`
      sleep(1)
      puts "Devise end: #{devise}"
    end
  end
end

Devise.new.check_devise_state
