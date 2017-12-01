require 'yaml'
require_relative "./base/http"
require_relative "devise"
class Hartbit
  include Base::Http
  include Devise
  SETTING_PATH= "/home/pi/workspace/remote_server/config.yml"

  def send_hartbit
    setting = YAML.load_file(SETTING_PATH)
    respond = _get(setting["interface"]["hartbit"]+"?space_code="+setting["space_code"]+"&cron="+setting["crontab_timestamp"]+"&cmd_quota"+setting["cmd_quota_timestamp"])
    # check crontab update
    update_crontab_request if(respond["update_cron"])
    # check activate update
    update_activate if(respond["activate_changed"])
    # check devise online status
    check_devise_state if(respond["new_devise"])
    # check cmd quota update
    update_cmd_quota if(respond["cmd_quota"])
  end
end

Hartbit.new.send_hartbit
