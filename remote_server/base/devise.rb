require 'redis'
require_relative './update_crontab'

module Base
  module Devise
    include UpdateCrontab

    def check_devise_state
      respond = _get(@setting["interface"]["get_devise_list"]+"?space_code="+@setting["space_code"])
      redis = ::Redis.new(host:'127.0.0.1', port: 6379)
      get_online_devise(respond["devise_list"])
      @logger.info("Server online devise list:#{respond['devise_list'].to_json}")
      online_devise = []
      times = 1
      respond["devise_list"].each do |code|
        while true do
          if(redis.exists("devise-online-#{code}"))
            online_devise << code if redis.get("devise-online-#{code}")=="true"
            break;
          end
          @logger.error("Devise online request failed. \n Server Respond:#{respond}.\n Online devise: #{online_devise}") and break if times > 20
          times += 1
          sleep(1)
        end
      end
      upload_online_state(online_devise)
      remove_inactive_devise_cron_job(respond["devise_list"]-online_devise)
    end

    def remove_inactive_devise_cron_job(remove_codes)
      @logger.info("Remove crontab devise:#{remove_codes.to_json}")
      update_crontab(remove_lines: remove_codes)
    end

    def upload_online_state(codes)
      @logger.info("Upload online devise list:#{codes.to_json}")
      params = {:space_code => @setting["space_code"], :codes => codes}
      _post(@setting["interface"]["upload_node_online_state"], params)
    end

    # respond: {devise_list=>["3813jd", "93jd81"]} node code list
    def get_online_devise(codes=[])
      #server_file = "/home/pi/workspace/raspi_net/server/server1"
      codes.each do |devise|
        #`sudo #{server_file} #{devise} ol`
        `/home/pi/.rvm/wrappers/ruby-2.2.3@rails5/ruby /home/pi/workspace/remote_server/new_job.rb #{devise}_ol`
      end
    end
  end
end
