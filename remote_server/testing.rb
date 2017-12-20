require 'yaml'
require "pry"
require "redis"
require_relative "./base/at_commands"
class Testing
  include Base::AtCommands

  SETTING_PATH= "/Users/wangzhao/workspace/arduino/raspi_net/remote_server/config.yml"

  def initialize
    @setting = YAML.load_file(SETTING_PATH)
    if init_sim
      puts "SIM card init successful!"
      http_get("http://312f128a.ngrok.io/spaces/hartbit?space_code=8a1isp", "")
    end
  end

end

Testing.new
