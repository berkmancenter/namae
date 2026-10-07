# BibTeX column names are aliases for the Namae parts.
PARTS = Hash.new { |_, key| key.to_sym }.merge(
  'first' => :given, 'von' => :particle, 'last' => :family, 'jr' => :suffix
)

def parts(name, columns)
  columns.to_h { |column| [column, name[PARTS[column]].to_s] }
end

Given(/^a parser that prefers commas as separators$/) do
  Namae::Parser.instance.options[:prefer_comma_as_separator] = true
end

Given(/^I want to include particles in the family name$/) do
  Namae::Parser.instance.options[:include_particle_in_family] = true
end

Given(/^I add "(.*)" to the (titles|trailing titles)$/) do |word, list|
  options = Namae::Parser.instance.options
  key = list == 'titles' ? :title : :trailing_title
  options[key] = options[key] + [word]
end

When(/^I parse the names? "(.*)"$/) do |string|
  @names = Namae.parse!(string)
end

Then(/^the parts should be:$/) do |table|
  row = table.hashes.first
  expect(@names.length).to eq(1)
  expect(parts(@names[0], row.keys)).to eq(row)
end

Then(/^the names should be:$/) do |table|
  expect(@names.length).to eq(table.hashes.length)
  table.hashes.each_with_index do |row, i|
    expect(parts(@names[i], row.keys)).to eq(row)
  end
end

Then(/^the list should (not )?be followed by others$/) do |negate|
  expect(@names.others?).to eq(!negate)
end
