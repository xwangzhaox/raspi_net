require 'yaml/store'
require 'pry'
module Base
  module UpdateCrontab
    # 请在执行前确保已经初始化了当前用户的crontab
    def update_crontab_request(init:false)
      respond = _get(@setting["interface"]["sync_crontab"]+"?space_code="+@setting["space_code"])
      if init
        hartbit = "*/1 * * * * /home/pi/.rvm/wrappers/ruby-2.2.3@rails5/ruby /home/pi/workspace/remote_server/hartbit.rb"
        devise = "0 */1 * * * /home/pi/.rvm/wrappers/ruby-2.2.3@rails5/ruby /home/pi/workspace/remote_server/devise.rb"
        init_lines = [hartbit, devise]
      end
      update_crontab(new_lines:respond["new_lines"], remove_lines:respond["remove_lines"], init_lines:init_lines)
      update_timestamp(self.class::SETTING_PATH, respond["timestamp"])
      @logger.info("[Update crontab] timestamp:#{respond['timestamp']}, new_lines:#{respond['new_lines']}, remove_lines:#{respond['remove_lines']}, init_lines:#{init_lines}")
    end

    def update_timestamp(setting_path, new_timestamp)
      store = YAML::Store.new setting_path
      store.transaction do
        store["crontab_timestamp"] = new_timestamp
      end
    end

    def update_crontab(new_lines:[], remove_lines:[], init_lines:[])
      tmp_file = "/tmp/crontab_#{Time.now.to_i}.bak"

      `crontab -l > #{tmp_file}`
      init_lines && init_lines.each do |line|
        `echo '#{line}' >> #{tmp_file}`
      end
      remove_lines && remove_lines.each do |action|
        `sed -i '/#{action.gsub(/ /, "_")}/d'  #{tmp_file}`
      end
      new_lines && new_lines.each do |line|
        `echo '#{line["timing_str"]} /home/pi/.rvm/wrappers/ruby-2.2.3@rails5/ruby /home/pi/workspace/remote_server/new_job.rb #{line["full_action"].gsub(/ /, "_")}' >> #{tmp_file}`
      end
     `crontab #{tmp_file}`
     `rm -rf #{tmp_file}`
    end
  end
end
