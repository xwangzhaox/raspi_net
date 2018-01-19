require 'redis'

class NewJob

  def initialize(full_action)
    redis = ::Redis.new(host:'127.0.0.1', port: 6379)
    redis.set("job_#{Time.now.to_i}_#{rand(9999)}", full_action)
  end
end

NewJob.new(ARGV[0])
