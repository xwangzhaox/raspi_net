require 'yaml'
require "pry"
require "redis"
require_relative "./base/http"
require_relative "./base/devise"
require_relative "./base/logger"

class Devise
  include Base::Http
  include Base::Devise
  include Base::Logger

  SETTING_PATH= "/home/pi/workspace/remote_server/config.yml"

  def initialize
    @setting = YAML.load_file(SETTING_PATH)
    @logger = init_logger
    @logger.info("Daily devise interface")
    check_devise_state
  end

end

Devise.new
