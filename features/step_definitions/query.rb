# Set ENV['CASS_KEYSPACE'], ENV['CASS_HOST'] and ENV['CASS_PORT'] to configure CQL client
#
Given /a CQL model definition:/ do |defn|
  # Define the new class in the context of the Cucumber world so its constant will
  # be swept away when the test case completes.
  @cql_model = eval(defn)
  options = {}
  options[:port] = ENV['CASS_PORT'] if ENV['CASS_PORT']
  options[:host] = ENV['CASS_HOST'] if ENV['CASS_HOST']
  options[:keyspace] = ENV['CASS_KEYSPACE'] if ENV['CASS_KEYSPACE']
  @client = Cql::Client.new(options)
  @cql_model.cql_client(@client)
  @cql_model
end

When /^I call: (.*)/ do |ruby|
  begin
    @call_return = @cql_model.instance_eval(ruby).to_s.strip
  rescue Exception => e
    @call_error = e
  end
end

When /^call: (.*)/ do |ruby|
  begin
    @call_return = @cql_model.instance_eval(ruby)
  rescue Exception => e
    @call_error = e
  end
end

Then /it should return: (.*)/ do |value|
  @call_return.inspect.should == value
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

Then /the model should respond to (.*)/ do |meth|
  @cql_model.new.should respond_to(meth.to_sym)
end

Then /^it should should be executed with :(\w+)$/ do |consist|
  each_row = double('each_row')
  each_row.stub(:each_row).and_return([])
  @client.should_receive(:execute).with(kind_of(String), consist.to_sym).and_return(each_row)
  @call_return.execute()
end

When /^try: (.*)/ do |ruby|
  @ruby_code = ruby
end

Then /^it should backup current keyspace, use '(\w+)' and restore previous one$/ do |keyspace|
  class TestClient
    def initialize
      @keyspace = 'old'
    end
    def keyspace
      @keyspace
    end
    def use(keyspace)
      @keyspace = keyspace
    end
  end
  @cql_model.cql_client(TestClient.new)
  @cql_model.should_receive(:insert) do
    @cql_model.cql_client.keyspace.should == keyspace
  end
  eval(@ruby_code)
  @cql_model.cql_client.keyspace.should == 'old'
end

