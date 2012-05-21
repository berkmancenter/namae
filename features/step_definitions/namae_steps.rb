When /^I parse the name "(.*)"$/ do |string|
  @name = Namae.parse!(string)[0]
end

When /^I parse the names "(.*)"$/ do |string|
  @names = Namae.parse!(string)
end


Then /^the parts should be:$/ do |table|
  table.hashes.each do |row|
    [@name.given, @name.particle, @name.family, @name.suffix].map(&:to_s).should ==
      row.values_at('first', 'von', 'last', 'jr')
  end
end
