# Set ENV['CASS_KEYSPACE'], ENV['CASS_HOST'] and ENV['CASS_PORT'] to configure CQL client
#
Given /a CQL model definition:/ do |defn|
  # Define the new class in the context of the Cucumber world so its constant will
  # be swept away when the test case complete.
  @cql_model = instance_eval(defn)
  options = {}
  options[:port] = ENV['CASS_PORT'] if ENV['CASS_PORT']
  options[:host] = ENV['CASS_HOST'] if ENV['CASS_HOST']
  options[:keyspace] = ENV['CASS_KEYSPACE'] if ENV['CASS_KEYSPACE']
  cql_client = Cql::Client.new(options)
  @cql_model.cql_client = cql_client
  @cql_model
end

When /I call: (.*)/ do |ruby|
  begin
    @call_return = @cql_model.instance_eval(ruby).to_s.strip
  rescue Exception => e
    @call_error = e
  end
end

Then /it should generate CQL( that includes)?: (.*)/ do |partial, cql|
  puts "***ERROR #{@call_error.message.inspect}\n#{@call_error.backtrace.join("\n")}" if @call_error
  @call_error.should be_nil
  cql.gsub!('<model_class>', @cql_model.table_name)
  @call_return.should =~ /#{Regexp.escape(cql) + (partial ? '.*' : '')};$/
end

Then /it should error with: (.*), (.*)/ do |klass, msg|
  @call_error.should_not be_nil
  @call_error.class.name.should == klass
  @call_error.message.should =~ Regexp.new(msg)
end

