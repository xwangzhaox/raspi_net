require 'pry'
require 'redis'
require_relative './base/logger'

class Worker
  include Base::Logger

  def initialize
    @redis = ::Redis.new(host:'127.0.0.1', port: 6379)
    @server_file = "/home/pi/workspace/raspi_net/server/server1"
    @logger = init_logger
  end

  def worker
    @logger.info("Start Worker")
    job_id = ""
    timer = 0
    while true
      if job_id = working_job and job_id!=""# 如果有正在跑的job，则计时
        # 如果计时器时差超过10秒，则kill进程
        if timer != 0 and (Time.now.to_i-timer>10)
          @logger.error("Job timeout. #{%x[ps -ef | grep server1| grep -v grep]}")
          %x[sudo kill -9 #{job_id}]
          timer = 0
        else
          timer = Time.now.to_i
        end
      elsif @redis.keys("job_*").size > 0
        timer = 0
        key = @redis.keys("job_*").first
        full_action = @redis.get(key).gsub(/_/, " ")
        @logger.info("Create new job. full_action(#{full_action})")
        @redis.del(key)
        `sudo #{@server_file} #{full_action}`
      end
      sleep 4
    end
  end

  def working_job
    %x[pgrep server1]
  end
end

Worker.new.worker
