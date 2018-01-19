require 'yaml'
require 'pry'
require_relative "./base/http"
require_relative './base/at_commands'
require_relative './base/update_crontab'
require_relative './base/emergency_respond'
require_relative './base/cmd_quota'
require_relative './base/devise'
require_relative './base/logger'

class Hartbit
  include Base::AtCommands
  include Base::UpdateCrontab
  include Base::EmergencyRespond
  include Base::CmdQuota
  include Base::Http
  include Base::Devise
  include Base::Logger

  SETTING_PATH= "/home/pi/workspace/remote_server/config.yml"

  def send_hartbit
    @setting = YAML.load_file(SETTING_PATH)
    @logger = init_logger
    respond = _get(@setting["interface"]["hartbit"]+"?space_code="+@setting["space_code"]+"&cron="+(@setting["crontab_timestamp"] || "")+"&cmd_quota="+(@setting["cmd_quota_timestamp"]||""))
    cron, activate, new_devise, cmd_quota = analyze_rcord(respond["rcord"])
    binding.pry
    @logger.info("Hartbit action: {cron: #{cron}, activate: #{activate}, new_devise:#{new_devise}, cmd_quota:#{cmd_quota}}")
    # check crontab update
    update_crontab_request if(cron)
    # check activate update
    update_activate if(activate)
    # check devise online status
    check_devise_state if(new_devise)
    # check cmd quota update
    update_cmd_quota if(cmd_quota)
  end

  private
  def analyze_rcord(rcord)
    case rcord.to_i
    when 0 then return false, false, false, false;
    when 1 then return true, false, false, false;
    when 3 then return false, true, false, false;
    when 5 then return false, false, true, false;
    when 11 then return false, false, false, true;

    when 4 then return true, true, false, false;
    when 6 then return true, false, true, false;
    when 8 then return false, true, true, false;
    when 12 then return true, false, false, true;
    when 14 then return false, true, false, true;
    when 16 then return false, false, true, true;

    when 19 then return false, true, true, true;
    when 17 then return true, false, true, true;
    when 15 then return true, true, false, true;
    when 9 then return true, true, true, false;
    when 20 then return true, true, true, true;
    else return false, false, false, false
    end
  end
end

Hartbit.new.send_hartbit
