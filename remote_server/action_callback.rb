require "yaml"
require "redis"
require "pry"
require "logger"
require_relative './base/at_commands'
require_relative './base/update_crontab'
require_relative './base/emergency_respond'
require_relative './base/http'

class ActionCallback
  include Base::AtCommands
  include Base::UpdateCrontab
  include Base::EmergencyRespond
  include Base::Http

  SETTING_PATH = '/home/pi/workspace/remote_server/config.yml'

  # e.g. node_code: g8dke3 action:2_g_th data:23.41_31.34
  def initialize(node_code, action, data)
    @setting = YAML.load_file(SETTING_PATH)
    #file = File.open('action_log.log', File::WRONLY | File::APPEND | File::CREAT)
    #@logger = Logger.new(file, 'daily', 10)
    #@logger.datetime_format = "%Y-%m-%d %H:%M:%S"
    @error_msg = ""
    @node_code = node_code
    @port = action.split("_").first
    @action = action.split("_")[1..-1].join("_")
    @firsthand_action = action
    @data = data
  end

  def validate_action
    if @firsthand_action.downcase == "ol"
      redis = ::Redis.new(host:'127.0.0.1', port:6379)
      redis.hset("devise-online", @node_code, true)
      return
    end
    if(@action[0]=="g")
      keys = @setting["cmd_quota"][@action.split("_").last]
      data = @data.split("_")
      Array(keys).each_with_index do |key, index|
        action_callback(key, data[index])
      end
    elsif @action[0]=="p"
      return
    end
   # if data.count>1 && @action[-2..-1]=="th"
   #   keys = ["temp", "humi"]
   #   data.each_with_index do |t_or_h, index|
   #     action_callback(keys[index], t_or_h.to_f)
   #   end
   # else
   #   action_callback(@action, @data)
   # end
  end

  def action_callback(action, params)
     @params = {
      :space_code => @setting["space_code"],
      :node_code => @node_code,
      :port => @port,
      :act => action,
	  :firsthand_action => @firsthand_action,
      :value => params
    }
    check_boundary_value(action, @note_code, @port, @params)
    send_to_remote_server
  end

  def send_to_remote_server
    _post(@setting["interface"]["upload_data"], @params)
  end
end

  #SocketClient.new(ARGV[0], ARGV[1], ARGV[2]).validate_action
  #SocketClient.new("o1zh6u", "A2_g_th", "39.10_83.31").validate_action
ActionCallback.new("o1zh6u", "OL", "").validate_action
