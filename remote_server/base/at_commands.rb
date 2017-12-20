require "serialport"

module Base
  module AtCommands
    def init_sim
      @sp = SerialPort.new("/dev/tty.SLAB_USBtoUART", 115200)
  	@sp.read_timeout = 100
      gprs_module_ready?
    end

    def http_post(url, params)
      execute_cmd(@setting["commands"]["http_init"])
      execute_cmd(@setting["commands"]["http_params_cid"])
      execute_cmd(@setting["commands"]["http_params_url"] + "\"#{url}\"")
      execute_cmd(@setting["commands"]["http_package_size"])
      execute_cmd(params)
      execute_cmd(@setting["commands"]["http_post_send"])
      respond = execute_cmd(@setting["commands"]["http_read"], :return_result=>true).lines[1..-2]
      execute_cmd(@setting["commands"]["http_close"])
      respond
    end

    def http_get(url, params)
      execute_cmd(@setting["commands"]["http_set_connection_gprs"])
      execute_cmd(@setting["commands"]["http_set_apn"])
      execute_cmd(@setting["commands"]["http_enable_gprs"])
      execute_cmd(@setting["commands"]["check_connection_get_ip"])
      execute_cmd(@setting["commands"]["http_init"])
      execute_cmd(@setting["commands"]["http_params_cid"])
      execute_cmd(@setting["commands"]["http_params_url"] + "\"#{url}\"")
      execute_cmd(@setting["commands"]["http_get_send"])
      respond = execute_cmd(@setting["commands"]["http_read"], :return_result=>true)
      execute_cmd(@setting["commands"]["http_close"])
      respond
    end

    private
    def execute_cmd(cmd, return_result: false)
      times = 1
      begin
        if(cmd.include?("AT+HTTPACTION"))
          while true
            @sp.write("#{cmd}\r")
            sleep(3)
            result = @sp.readlines
            raise "GET Request ERROR(#{result})!" and break if result.any?{|r|r.include?("ERROR")}
            if result.last =~ /HTTPACTION. \d*,(\d*),\d*/
              raise "Request Error(#{$1})" if $1.to_i >= 600
              break
            end
          end
        else
          @sp.write("#{cmd}\r")
          result = @sp.readlines
        end
        puts result
        raise "AT Command execute error(#{cmd}): #{result}\n" if !result.nil? and result.include?("ERROR")
      rescue
        puts times
        if times < 4
          times += 1 and retry
        end
        times = 1
        puts "AT Command request error: #{$!}"
        $@.each do |line|
          puts line
        end
      end
      return result if return_result
      @error_msg.nil? ? true : false
    end

    def gprs_module_ready?
      execute_cmd(@setting["commands"]["at"]) &&
      execute_cmd(@setting["commands"]["ate_open"]) &&
      execute_cmd(@setting["commands"]["sim_setup"]) &&
      execute_cmd(@setting["commands"]["signal_intensity"]) &&
      execute_cmd(@setting["commands"]["gprs_signed_in"]) &&
      execute_cmd(@setting["commands"]["attachemnt"])
    end
  end
end
