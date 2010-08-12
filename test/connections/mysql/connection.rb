print "Using Mysql\n"
require 'logger'

ActiveRecord::Base.logger = Logger.new("debug.log")

ActiveRecord::Base.configurations = {
  'reptest' => {
    :adapter  => 'mysql',
    :database => 'repertoire_testing',
    :min_messages => 'warning'
  }
}

ActiveRecord::Base.establish_connection 'reptest'
