When /^I parse the name "(.*)"$/ do |string|
  @name = Namae.parse!(string)[0]
end

When /^I parse the names "(.*)"$/ do |string|
  @names = Namae.parse!(string)
end


Then /^the BibTeX parts should be:$/ do |table|
  table.hashes.each do |row|
    @name.values_at(:given, :particle, :family, :suffix).map(&:to_s).should ==
      row.values_at('first', 'von', 'last', 'jr')
  end
end

Then /^the parts should be:$/ do |table|
  table.hashes.each do |row|
    @name.values_at(:given, :particle, :family, :suffix, :title, :appellation, :nick).map(&:to_s).should ==
      row.values_at('given', 'particle', 'family', 'suffix', 'title', 'appellation', 'nick')
  end
end

Then /^there should be (\d+) names$/ do |count|
  @names.length.should == count.to_i
end

Then /^the names should be:$/ do |table|
  table.hashes.each_with_index do |row, i|
    @names[i].values_at(*row.keys.map(&:to_sym)).map(&:to_s).should == row.values
  end
end