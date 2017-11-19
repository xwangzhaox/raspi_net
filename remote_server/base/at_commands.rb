require "serialport"

module AtComand
  def init_sim
    @sp = SerialPort.new("/dev/ttyAMA0", 115200)
	@sp.read_timeout = 100
    gprs_module_ready?
  end

  def http_post(url, params)
    execute_cmd(setting["commands"]["http_init"])
    execute_cmd(setting["commands"]["http_params_cid"])
    execute_cmd(setting["commands"]["http_params_url"] + "\"#{url}\"")
    execute_cmd(setting["commands"]["http_package_size"])
    execute_cmd(params)
    execute_cmd(setting["commands"]["http_send"])
    respond = execute_cmd(setting["commands"]["http_read"], :return_result=>true).lines[1..-2]
    execute_cmd(setting["commands"]["http_close"])
    respond
  end

  private
  def execute_cmd(cmd, return_result: false)
    @sp.write("#{cmd}\r")
    begin
      result = @sp.readlines
      @error_msg = "Command(#{cmd}) not support. Error: #{result}\n" if result.include?("ERROR")
    rescue
      @error_msg = "Writing serial port error\n"
    end
    return result if return_result
    (@error_msg.nil? or @error_msg.blank?) ? true : false
  end

  def gprs_module_ready?
    setting = {"space_code"=>"j3ke8c", "crontab_timestamp"=>"", "interface"=>{"upload_data"=>"", "get_corntab_lines"=>"", "get_boundary_list"=>""}, "commands"=>{"at"=>"AT", "ate_close"=>"ATE0", "ate_open"=>"ATE1", "sleep_mode_close"=>"AT%SLEEP=0", "sleep_mode_open"=>"AT%SLEEP=0", "sim_setup"=>"AT+CPIN?", "signal_intensity"=>"AT+CSQ", "gsm_sign_in_prompt"=>"AT+CREG=1", "gsm_signed_in"=>"AT+CREG?", "gprs_sign_in_prompt"=>"AT+CGREG=1", "gprs_signed_in"=>"AT+CGREG?", "attachemnt"=>"AT+CGATT=1", "attachemnt_ready"=>"AT+CGATT?", "http_init"=>"AT+HTTPINIT", "http_params_cid"=>"AT+HTTPPARA=\"CID\",1", "http_params_url"=>"AT+HTTPPARA=\"URL\",", "http_context"=>"AT+HTTPPARA=\"CONTENT\",\"application/json\"", "http_package_size"=>"AT+HTTPDATA=40,10000", "http_send"=>"AT+HTTPACTION=1", "http_read"=>"AT+HTTPREAD", "http_close"=>"AT+HTTPTERM"}}
    execute_cmd(setting["commands"]["at"]) &&
    execute_cmd(setting["commands"]["ateo"]) &&
    execute_cmd(setting["commands"]["sim_setup"]) &&
    execute_cmd(setting["commands"]["signal_intensity"]) &&
    execute_cmd(setting["commands"]["gprs_signed_in"]) &&
    execute_cmd(setting["commands"]["attachemnt"])
  end
end
