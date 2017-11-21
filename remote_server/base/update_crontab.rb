module Base
  module UpdateCrontab
    def update_timestamp(new_timestamp)
      setting_file[:timestamp] = new_timestamp
      setting_file.save
    end

    def update_crontab(new_lines, remove_lines)
      tmp_file = "/tmp/crontab_#{time.now.to_i}.bak"
      `crontab -l > #{tmp_file}`
      remove_lines.each do |line|
        `sed -i '#{line}'  #{tmp_file}`
      end
      new_lines.each do |line|
        `echo '#{line}' >> #{tmp_file}`
      end
     `crontab #{tmp_file}`
    end
  end
end
