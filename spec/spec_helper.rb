require 'rubygems'
require 'merb-core'
require 'spec'

require 'dm-core'

$TESTING=true
# $:.push File.join(File.dirname(__FILE__), '..', 'lib')   # CWY: is this necessary?

module Merb
  def self.orm
    :datamapper
  end
end

ENV['ADAPTER'] ||= 'postgres'

# Set up database for integration tests
DataMapper.setup(:default, 'postgres://postgres@localhost/repertoire_testing')

# Using Merb.root below makes sure that the correct root is set for
# - testing standalone, without being installed as a gem and no host application
# - testing from within the host application; its root will be used
Merb.start_environment(
  :testing => true, 
  :adapter => 'runner', 
  :environment => ENV['MERB_ENV'] || 'test',
  :merb_root => Merb.root
)