require 'sucker_punch'

class Job
  include SuckerPunch::Job
end

Dir[File.join(__dir__, 'jobs', '*.rb')].each do |file|
  require file
end
