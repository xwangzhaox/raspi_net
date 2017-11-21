require 'yaml'
require_relative "./base/http"
class Hartbit
  include Base::Http

  def send_hartbit
    setting = YAML.load_file("./config.yml")
    _get(setting["interface"]["hartbit"]+"?space_code="+setting["space_code"])
  end
end

Hartbit.new.send_hartbit
