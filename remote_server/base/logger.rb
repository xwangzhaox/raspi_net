require 'logger'

module Base
  module Logger
    def init_logger
      file = open("/home/pi/workspace/raspi_net/remote_server/log/"+(Time.now).strftime("%Y-%m-%d")+"_cronjob.log", File::WRONLY | File::APPEND | File::CREAT)
      logger = ::Logger.new(file, 'daily')
      logger.datetime_format = "%Y-%m-%d %H:%M:%S"
      file.sync = true
      return logger
    end
  end
end
