require 'yaml/store'
require_relative './base/at_commands'
require_relative './base/update_crontab'
require_relative './base/emergency_respond'
require_relative './base/cmd_quota'
require_relative './base/http'
require_relative './base/devise'

class Configuration
  include Base::AtCommands
  include Base::UpdateCrontab
  include Base::EmergencyRespond
  include Base::CmdQuota
  include Base::Http
  include Base::Devise

  SETTING_PATH= "/home/pi/workspace/remote_server/config.yml"

  def initialize(space_code)
    if space_code.nil?
      raise "Error: space_code could not be blank."
    end
    @setting = YAML.load_file(SETTING_PATH)
    init_space_code(SETTING_PATH, space_code)
  end

  def init_space
    update_crontab_request(init: true)
    update_cmd_quota
    update_activate
    check_devise_state
  end

  private
  def init_space_code(setting_path, space_code)
    store = YAML::Store.new setting_path
    store.transaction do
      store["space_code"] = space_code
    end
  end
end
Configuration.new(ARGV[0]).init_space
