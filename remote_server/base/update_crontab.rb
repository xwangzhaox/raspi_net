require 'yaml/store'
module Base
  module UpdateCrontab
    def update_timestamp(setting_path, new_timestamp)
      store = YAML::Store.new setting_path
      store.transaction do
        store["crontab_timestamp"] = new_timestamp
      end
    end

    def update_crontab(new_lines, remove_lines)
      log_file = "/home/pi/workspace/remote_server/execute_cmd_log.log"
      server_file = "/home/pi/workspace/raspi_net/server/server1"
      tmp_file = "/tmp/crontab_#{Time.now.to_i}.bak"
      `crontab -l > #{tmp_file}`
      remove_lines.each do |action|
        `sed -i '#{action}'  #{tmp_file}`
      end
      new_lines.each do |line|
        `echo '#{line["timing_str"]} sudo #{server_file} #{line["full_action"]} > #{log_file}' >> #{tmp_file}`
      end
     `crontab #{tmp_file}`
     `rm -rf #{tmp_file}`
    end
  end
end
