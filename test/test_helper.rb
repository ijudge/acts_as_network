$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'test/unit'
require 'test/unit/testcase'
# 



require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'rubygems'
require 'active_record'
require 'active_record/fixtures'
require 'active_support/testing/setup_and_teardown'

config = YAML::load(IO.read( File.join(File.dirname(__FILE__),'database.yml')))

# In rails 2.3 , the code to implement fixtures was moved from ActiveSupport::TestCase
# into ActiveRecord::TestFixtures, and this module is not included in 
#ActiveSupport::TestCase by default

class ActiveSupport::TestCase
  begin
    include ActiveRecord::TestFixtures
  rescue NameError
    puts "You appear to be using a pre-2.3 version of Rails. No need to include ActiveRecord::TestFixtures..."
  end
end

TEST_CASE = ActiveSupport.const_defined?(:TestCase) ? ActiveSupport::TestCase : Test::Unit::TestCase

# cleanup logs and databases between test runs
#FileUtils.rm File.join(File.dirname(__FILE__), "debug.log"), :force => true
FileUtils.rm File.join(RAILS_ROOT, config['sqlite3'][:dbfile]), :force => true

ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3'])

load(File.join(File.dirname(__FILE__), "schema.rb"))

TEST_CASE.fixture_path = File.dirname(__FILE__) + "/fixtures/"
$LOAD_PATH.unshift(TEST_CASE.fixture_path)

class TEST_CASE #:nodoc:
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(TEST_CASE.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(TEST_CASE.fixture_path, table_names)
    end
  end

  # Turn off transactional fixtures if you're working with MyISAM tables in MySQL
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where you otherwise would need people(:david)
  self.use_instantiated_fixtures  = false
  
  # Instantiated fixtures are slow, but give you @david where you otherwise would need people(:david)
  
end