require 'yaml'
require "pry"
require "redis"
require_relative "./base/http"
require_relative "./base/devise"
class Devise
  include Base::Http
  include Base::Devise
  SETTING_PATH= "/home/pi/workspace/remote_server/config.yml"

  def initialize
    @setting = YAML.load_file(SETTING_PATH)
    check_devise_state
  end

end

Devise.new
