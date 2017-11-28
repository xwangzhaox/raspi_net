require 'sqlite3'

module Base
  module EmergencyRespond
    def check_boundary_value(value_type, node_code, port, params)
      if db = load_db_and_table
        sql = "SELECT l_or_h,value,action FROM emergency_treatments WHERE code_port_str = '#{node_code}_#{port}' and value_type='#{value_type}'"
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

    def update_emergency_treatment_list(list)
      if db = load_db_and_table
        sql = "INSERT INTO emergency_treatments VALUES"
        sql += list.inject("") do |result, item|
          item.first.match(/(.*_.*)_(.*)/)
          result += "('#{item.value_type} #{$1}', '#{$2}', #{item.last["value"]}, '#{item.last["action"]}'),"
        end
        sql[-1] = ";"
        puts sql
        db.execute(sql)
      end
    end

    def load_db_and_table(db_name="./emergency_treatment.db")
      db = ::SQLite3::Database.new db_name
      result = db.execute("SELECT COUNT(*) FROM sqlite_master where type='table' and name='emergency_treatments'")
      if result[0][0]==0
        sql = "create table emergency_treatments(" \
                 "value_type varchar(5)," \
                 "code_port_str varchar(30)," \
                 "l_or_h varchar(5)," \
                 "value float," \
                 "action varchar(30))"
        db.execute(sql)
      end
      db
    end

    def execute_cmd full_action
      log_file = "/home/pi/workspace/remote_server/execute_cmd_log.log"
      server_file = "/home/pi/workspace/raspi_net/server/server1"
      `sudo #{server_file} #{full_action} > #{log_file}`
    end
  end
end
