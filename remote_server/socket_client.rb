require "yaml"
require "logger"
require 'pry'
require_relative './base/at_commands'
require_relative './base/update_crontab'
require_relative './base/emergency_respond'
require_relative './base/http'

class SocketClient
  include Base::AtCommands
  include Base::UpdateCrontab
  include Base::EmergencyRespond
  include Base::Http

  SETTING_PATH = './config.yml'

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
    data = @data.split("_")
    if data.count>1 && @action[-2..-1]=="th"
      keys = ["temp", "humi"]
      data.each_with_index do |t_or_h, index|
        action_callback(keys[index], t_or_h.to_f)
      end
	else
      action_callback(@action, @data)
    end
  end

  def action_callback(action, params)
     @params = {
      :space_code => @setting["space_code"],
      :cron_timestamp => @setting["crontab_timestamp"],
      :node_code => @node_code,
      :port => @port,
      :act => action,
	  :firsthand_action => @firsthand_action,
      :value => params
    }
    # check_boundary_value(note_code, port, @params)
    send_to_remote_server
  end

  def send_to_remote_server
    if true#init_sim
      # respond = http_post(setting[:interface][:upload_data], @params)
      respond = _post(@setting["interface"]["upload_data"], @params)

      if(respond[:rcord]==1)
        if(respond[:crontab_changed])
          cron_respond = _get(@setting["interface"]["get_corntab_lines"]+"?space_code="+setting[:space_code])
          update_crontab(cron_respond[:new_lines], cron_respond[:remove_lines])
          update_timestamp(cron_respond[:timestamp])
        end

        if(respond[:emergency_treatment_list_changed])
          emergency_treatment_respond = _get(@setting["interface"]["get_boundary_list"]+"?space_code="+setting[:space_code])
          update_boundary_value_list(emergency_treatment_respond)
        end
      end
    else
      raise "[" + Time.now.strftime("%T") + "] " + @error_msg
    end
  end

  def online
    _post(setting[:interface][:online])
  end

  def init_crontab
    cron_respond = _get(@setting["interface"]["get_corntab_lines"]+"?space_code="+@setting["space_code"])
    update_crontab(cron_respond[:new_lines], cron_respond[:remove_lines])
    update_timestamp(cron_respond[:timestamp])
  end
end

  #SocketClient.new(ARGV[0], ARGV[1], ARGV[2]).validate_action
  SocketClient.new("o1zh6u", "2_p_on_30", "").validate_action
