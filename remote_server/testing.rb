require 'yaml/store'
require 'redis'
require 'pry'
require_relative './base/at_commands'
require_relative './base/update_crontab'
require_relative './base/emergency_respond'
require_relative './base/cmd_quota'
require_relative './base/http'

class Testing
  include Base::AtCommands
  include Base::UpdateCrontab
  include Base::EmergencyRespond
  include Base::CmdQuota
  include Base::Http

  SETTING_PATH= "/home/pi/workspace/remote_server/config.yml"

  def initialize
    @setting = YAML.load_file(SETTING_PATH)
  end

  def init_space
   # update_crontab_request(init: true)
   # update_cmd_quota
   # update_activate
   autoload :Devise, './devise'
    Devise.new
  end

end
Testing.new.init_space
