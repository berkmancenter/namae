
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'namae'

name1_s = 'Foo Bar'
name2_s = 'Baz'

name1 = Namae.parse(name1_s).first
r1 = [name1.given, name1.family]

name2 = Namae.parse(name2_s).first
r2 = [name2.given, name2.family]

$issues = []

def verify(str, expected)
  name = Namae.parse(str).first
  if name == nil
    $issues << {error: 'Parser returned nil'}
    return
  end

  result = [name.given, name.family]

  if result != expected
    $issues << {
      name: str,
      expected: expected,
      result: result,
    }
  end
end

N = 10_000

[[name1_s, r1], [name2_s, r2]].map do |str, expected|
  Thread.new do
    N.times do
      verify(str, expected)
    end
  end
end.each(&:join)

require 'pp'
pp $issues
