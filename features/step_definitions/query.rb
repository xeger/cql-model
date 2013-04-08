Given /a CQL model definition:/ do |defn|
  # Define the new class in the context of the Cucumber world so its constant will
  # be swept away when the test case complete.
  @cql_model = instance_eval(defn)
  @cql_model
end

When /I call: (.*)/ do |ruby|
  @call_return = @cql_model.instance_eval(ruby)
end

Then /it should generate CQL: (.*)/ do |cql|
  @call_return.to_s.strip.should =~ /#{Regexp.escape(cql)};$/
end