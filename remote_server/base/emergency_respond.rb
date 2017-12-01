require_relative "db"
module Base
  module EmergencyRespond
    include Db

    def update_activate
      respond = _get(@setting["interface"]["sync_activate"]+"?space_code="+@setting["space_code"])
      update_activate_list(respond)
    end

    def check_boundary_value(value_type, node_code, port, params)
      if db = load_db
        sql = "SELECT l_or_h,value,action FROM activates WHERE code_port_str = '#{node_code}_#{port}' and value_type='#{value_type}'"
        result = db.execute(sql)
        result.each do |item|
          if item.l_or_h=="low" && params<item.value # <
            execute_cmd(item.action)
          elsif item.l_or_h=="high" && params>item.value # >
            execute_cmd(item.action)
          end
        end
      end
    end

    def update_activate_list(list)
      if db = load_db
        sql = "INSERT INTO activates VALUES"
        sql += list.inject("") do |result, item|
          item.first.match(/(.*_.*)_(.*)_(.*)/)
          result += "('#{$3}', '#{$1}', '#{$2}', #{item.last["value"]}, '#{item.last["action"]}'),"
        end
        sql[-1] = ";"
        puts sql
        db.execute(sql)
      end
    end

    def execute_cmd full_action
      log_file = "/home/pi/workspace/remote_server/execute_cmd_log.log"
      server_file = "/home/pi/workspace/raspi_net/server/server1"
      `sudo #{server_file} #{full_action} > #{log_file}`
    end
  end
end
