print "Using PostgreSQL\n"
require 'logger'

ActiveRecord::Base.logger = Logger.new("debug.log")

ActiveRecord::Base.configurations = {
  'reptest' => {
    :adapter  => 'postgresql',
    :database => 'repertoire_testing',
    :username => 'postgres',
    :min_messages => 'warning'
  }
}

ActiveRecord::Base.establish_connection 'reptest'
