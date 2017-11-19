require "yaml"
require "logger"
require "./base/at_command"
require "./base/update_crontab"
require "./base/emergency_respond"
require "./base/http"

class SocketClient
  include AtCommand
  include UpdateCrontab
  include EmergencyRespond
  include Http

  SETTING_PATH = './config.yml'

  def initerize
    @setting = YAML.load(SETTING_PATH)
    #file = File.open('action_log.log', File::WRONLY | File::APPEND | File::CREAT)
    #@logger = Logger.new(file, 'daily', 10)
    #@logger.datetime_format = "%Y-%m-%d %H:%M:%S"
    @error_msg = ""
  end

  def action_callback(note_code, port, action, params)
     @params = {
      :space_code => @setting[:space_code],
      :timestamp => @setting[:crontab_timestamp],
      :note_code => note_code,
      :action => action,
      :port => port,
      :data => params
    }
    check_boundary_value(note_code, port, @params)
  end

  def send_to_remote_server
    if true#init_sim
      # respond = http_post(setting[:interface][:upload_data], @params)
      respond = _post(setting[:interface][:upload_data], @params)
      if(respond[:crontab_changed])
        cron_respond = _get(setting[:interface][:get_corntab_lines]+"?space_code="+setting[:space_code])
        update_crontab(cron_respond[:new_lines], cron_respond[:remove_lines])
        update_timestamp(cron_respond[:timestamp])
      end

      if(respond[:emergency_treatment_list_changed])
        emergency_treatment_respond = _get(setting[:interface][:get_boundary_list]+"?space_code="+setting[:space_code])
        update_boundary_value_list(emergency_treatment_respond)
      end
    else
      raise "[" + Time.now.strftime("%T") + "] " + @error_msg
    end
  end

  def online
    _post(setting[:interface][:online])
  end

  def init_crontab
    cron_respond = _get(setting[:interface][:get_corntab_lines]+"?space_code="+setting[:space_code])
    update_crontab(cron_respond[:new_lines], cron_respond[:remove_lines])
    update_timestamp(cron_respond[:timestamp])
  end
end
