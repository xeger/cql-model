Given /a CQL model/ do
  @cql_model = Class.new(Object)
  @cql_model.instance_eval do
    include CQLModel::Model
  end
end

When /I call: (.*)/ do |ruby|
  @call_return = @cql_model.instance_eval(ruby)
end

Then /it should generate CQL: (.*)/ do |cql|
  @call_return.to_s.strip.should =~ /#{Regexp.escape(cql)};$/
end